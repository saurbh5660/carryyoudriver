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

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          handleNavigation(data);
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Only run UI/Listener logic if not in a background isolate
    if (!GetPlatform.isWeb) {
      _requestFullPermissions();
      initFirebaseListeners();
    }
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

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // --- CRITICAL FOR SPLASH SCREEN ---
  Future<bool> checkInitialMessage() async {
    // 1. Check if app was opened via Firebase (Notification Payload)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      handleNavigation(initialMessage.data, isColdStart: true);
      return true;
    }

    // 2. Check if app was opened via Local Notification (Data-only Payload)
    final NotificationAppLaunchDetails? details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      String? payload = details!.notificationResponse?.payload;
      if (payload != null) {
        Map<String, dynamic> data = jsonDecode(payload);
        handleNavigation(data, isColdStart: true);
        return true;
      }
    }
    return false;
  }

  void initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground Data Received: ${message.data}");
      if (Get.currentRoute == AppRoutes.chatScreen &&
          message.data['type'] == "1") {
        debugPrint("Chat open → suppress notification");
        return;
      }
      if (GetPlatform.isAndroid) {
        if (DbHelper().getUserToken() != null) {
          showNotifications(message);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification Tapped (Background): ${message.data}");
      handleNavigation(message.data);
    });
  }

  Future<void> showNotifications(RemoteMessage message) async {
    int id = Random().nextInt(900) + 10;
    String payloadData = jsonEncode(message.data);
    String title = "OcYM Global";
    String body = message.data['message'] ?? "New Notification";

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: "@mipmap/ic_launcher",
          color: AppColor.yellowColor,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payloadData,
    );
  }

  void handleNavigation(
    Map<String, dynamic> data, {
    bool isColdStart = false,
  }) async {
    debugPrint("Navigating with Map Data: $data");

    String type = data['type']?.toString() ?? "";
    String requestId = data['requestId']?.toString() ?? "";
    String senderId = data['senderId']?.toString() ?? "";

    void navigate(String route, {Map<String, dynamic>? args}) {
      if (isColdStart) {
        Get.offAllNamed(route, arguments: args);
      } else {
        Get.toNamed(route, arguments: args);
      }
    }

    // switch (type) {
    //   case "1":
    //     navigate(AppRoutes.chatScreen, args: {'receiverId': senderId});
    //     break;
    //
    //   case "2":
    //     navigate(
    //       AppRoutes.postDetail,
    //       args: {'id': requestId, "from": "comment"},
    //     );
    //     break;
    //
    //   case "3":
    //     navigate(AppRoutes.otherProfile, args: {'id': senderId});
    //     break;
    //
    //   case "4":
    //     navigate(AppRoutes.postDetail, args: {'id': requestId});
    //     break;
    //
    //   case "5":
    //     navigate(
    //       AppRoutes.singleLiveStream,
    //       args: {
    //         'liveStreamId': requestId,
    //         'username': data['name'] ?? "Live User",
    //         'image': data['image'] ?? "",
    //       },
    //     );
    //     break;
    //
    //   case "6":
    //     navigate(AppRoutes.orderDetailScreen, args: {'orderId': requestId});
    //     break;
    //
    //   case "40":
    //     navigate(AppRoutes.eventDetail, args: {'eventId': requestId});
    //     break;
    //
    //   case "41":
    //     navigate(
    //       AppRoutes.basketBallDetail,
    //       args: {'from': 'basket_schedule', "id": requestId, 'where': "noti"},
    //     );
    //     break;
    //
    //   case "42":
    //     navigate(
    //       AppRoutes.classDetailScreen,
    //       args: {'from': 'classes', "id": requestId, "where": "noti"},
    //     );
    //     break;
    //
    //   case "43":
    //     navigate(
    //       AppRoutes.basketBallDetail,
    //       args: {'from': 'fitness', "id": requestId, "where": "noti"},
    //     );
    //     break;
    //
    //   default:
    //     navigate(AppRoutes.notificationScreen);
    // }
  }

}
