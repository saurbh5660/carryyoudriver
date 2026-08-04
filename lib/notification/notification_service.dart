import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../common/app_colors.dart';
import '../common/db_helper.dart';
import '../firebase_options.dart';
import '../routes/app_routes.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _localNotificationsInitialized = false;

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  /// Dedicated channel for notification `type == "1"`.
  AndroidNotificationChannel type1Channel = const AndroidNotificationChannel(
    'type1_channel_custom_sound',
    'Ride Requests',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('type1_sound'),
  );

  /// iOS foreground remote notifications are presented by APNs/Firebase.
  /// Dart local notification display remains Android-only.
  static const bool _enableIosForegroundPresentation = true;

  Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if (GetPlatform.isAndroid) {
      await _initializeLocalNotifications();
    }

    // Only run UI/listener logic in the main isolate.
    try {
      await _requestFullPermissions();
    } catch (e, stackTrace) {
      debugPrint("Notification permission setup failed: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
    initFirebaseListeners();
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher_foreground');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final decoded = jsonDecode(response.payload!);
            if (decoded is Map<String, dynamic>) {
              handleNavigation(decoded);
            }
          } catch (e) {
            debugPrint("Invalid notification payload: $e");
          }
        }
      },
    );

    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);
    await androidImpl?.createNotificationChannel(type1Channel);
    _localNotificationsInitialized = true;
  }

  Future<void> _requestFullPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    if (GetPlatform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    await setIosForegroundAlertsEnabled(_enableIosForegroundPresentation);
  }

  /// Enable/disable iOS auto-presentation of foreground push notifications.
  ///
  /// iOS displays foreground remote notifications via the OS based on what was
  /// last set with `setForegroundNotificationPresentationOptions`. Call this
  /// with `false` when the user enters a screen where notifications should be
  /// muted (e.g. the chat screen), and `true` again when they leave.
  Future<void> setIosForegroundAlertsEnabled(bool enabled) async {
    if (!GetPlatform.isIOS) return;
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: enabled,
          badge: enabled,
          sound: enabled,
        );
  }

  Future<bool> checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      handleNavigation(initialMessage.data, isColdStart: true);
      return true;
    }

    if (GetPlatform.isAndroid) {
      final NotificationAppLaunchDetails? details =
          await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        String? payload = details!.notificationResponse?.payload;
        if (payload != null) {
          Map<String, dynamic> data = jsonDecode(payload);
          handleNavigation(data, isColdStart: true);
          return true;
        }
      }
    }
    return false;
  }

  void initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        try {
          debugPrint("NOTIFICATION_TRACE foreground message start");
          debugPrint(
            "Foreground notification Received title: ${message.notification?.title}",
          );
          debugPrint(
            "Foreground notification Received body: ${message.notification?.body}",
          );
          debugPrint("Foreground Data Received: ${message.data}");

          if (GetPlatform.isIOS) {
            debugPrint("NOTIFICATION_TRACE iOS foreground handled by APNs");
            return;
          }

          if (Get.currentRoute == AppRoutes.chatScreen &&
              message.data['type'] == "12") {
            debugPrint("Chat open -> suppress notification");
            return;
          }

          if (DbHelper().getUserToken() != null) {
            unawaited(showNotifications(message));
          }
          debugPrint("NOTIFICATION_TRACE foreground message complete");
        } catch (e, stackTrace) {
          debugPrint("Foreground notification listener failed: $e");
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint("FirebaseMessaging.onMessage stream error: $error");
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        try {
          debugPrint("Notification Tapped (Background): ${message.data}");
          handleNavigation(message.data);
        } catch (e, stackTrace) {
          debugPrint("Notification tap handler failed: $e");
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint("FirebaseMessaging.onMessageOpenedApp stream error: $error");
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  Future<void> showNotifications(RemoteMessage message) async {
    try {
      if (GetPlatform.isIOS) return;

      await _initializeLocalNotifications();

      int id = Random().nextInt(900) + 10;
      String payloadData = jsonEncode(message.data);
      String title =
          message.data['title']?.toString() ??
          message.notification?.title ??
          "CarryU";
      String body =
          message.data['message']?.toString() ??
          message.notification?.body ??
          "";

      // type "1" gets its own channel + custom sound.
      final bool isType1 = message.data['type']?.toString() == "1";
      final AndroidNotificationChannel activeChannel = isType1
          ? type1Channel
          : channel;

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            activeChannel.id,
            activeChannel.name,
            // Small status-bar icon must be a white/alpha-only silhouette per
            // Android 5+ spec; using @mipmap/ic_launcher renders as a blank
            // white square.
            icon: 'ic_launcher_foreground',
            color: AppColor.yellowColor,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: isType1
                ? const RawResourceAndroidNotificationSound('type1_sound')
                : null,
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: isType1 ? 'type1_sound.caf' : null,
          ),
        ),
        payload: payloadData,
      );
    } catch (e, stackTrace) {
      debugPrint("Failed to show notification: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void handleNavigation(
    Map<String, dynamic> data, {
    bool isColdStart = false,
  }) async {
    debugPrint("Navigating with Map Data: $data");

    String type = data['type']?.toString() ?? "";
    String senderId = data['senderId']?.toString() ?? "";
    String fullName = data['senderName']?.toString() ?? "";
    String profilePic = data['senderProfile']?.toString() ?? "";
    String name = fullName.isNotEmpty ? fullName.split(' ').first : "";
    void navigate(String route, {Map<String, dynamic>? args}) {
      if (isColdStart) {
        Get.offAllNamed(route, arguments: args);
      } else {
        Get.toNamed(route, arguments: args);
      }
    }

    switch (type) {
      case "12":
        navigate(
          AppRoutes.chatScreen,
          args: {'id': senderId, "name": name, "image": profilePic},
        );
        break;
      case "1":
        navigate(AppRoutes.homeScreen);
        break;
      default:
        navigate(AppRoutes.notificationScreen);
    }
  }
}
