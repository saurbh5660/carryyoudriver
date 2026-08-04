import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../network/api_constants.dart';
import 'apputills.dart';
import 'db_helper.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  static const bool _listenToCreateBooking = true;

  factory SocketService() => _instance;
  IO.Socket? socket;
  final List<SocketListener> _listeners = [];
  Function(dynamic data,String eventType)? onListener;

  SocketService._internal();

  void addListener(SocketListener socketListener) {
    if (!_listeners.contains(socketListener)) {
      _listeners.add(socketListener);
    }
  }

  void removeListener(SocketListener socketListener) {
    _listeners.remove(socketListener);
  }

  @Deprecated('Use addListener instead')
  void setListener(SocketListener socketListener) {
    addListener(socketListener);
  }

  void connectToServer() {
    if (socket == null || !socket!.connected) {
      socket = IO.io(ApiConstants.socketUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .build());

      socket?.onConnect((_) {
        print('Connected to socket server');
        connectUser();
      });

      socket?.onDisconnect((_) {
        print('Disconnected from socket server');
      });

      _setupListeners();
    }
  }

  void connectUser() {
    final senderId = DbHelper().getUserModel()?.id.toString();
    if (senderId != null) {
      socket?.emit('connect_user', {'userId': senderId});
      connectUserListener();
    }
  }

  void connectUserListener() {
    socket?.on('connect_user_listener', (data) {
      print('User connected: $data');
    });
  }

  void userConstantList(String senderId) {
    Logger().d(senderId);
    socket?.emit('user_constant_list', {'senderId': senderId});
  }

  void updateStatus(Map<String, dynamic> messageData) {
    socket?.emit('update_route', messageData);
  }

  void updateNavigationStatus(Map<String, dynamic> messageData) {
    socket?.emit('startNavigation', messageData);
  }

  void locationUpdate(Map<String, dynamic> messageData) {
    socket?.emit('loction_update', messageData);
  }

  void driverLocationUpdate(Map<String, dynamic> messageData) {
    socket?.emit('driver_location_update', messageData);
  }

  void sendMessage(Map<String, dynamic> messageData) {
    socket?.emit('send_message', messageData);
  }

  void getMessages(Map<String, dynamic> messageData) {
    socket?.emit('users_chat_list', messageData);
  }


  void _setupListeners() {
    socket?.on('update_route_listener', (data) {
      printPrettyJson(data);
      _notifyListeners(data, 'update_route_listener');
    });

    socket?.on('manager_route_listener', (data) {
      printPrettyJson(data);
      _notifyListeners(data, 'manager_route_listener');
    });

    socket?.on('loction_update', (data) {
      printPrettyJson(data);
      Logger().d("location updated successfully");
      _notifyListeners(data, 'loction_update');
    });

    socket?.on('user_location_update', (data) {
      printPrettyJson(data);
      Logger().d("location updated successfully");
      _notifyListeners(data, 'user_location_update');
    });

    if (_listenToCreateBooking) {
      socket?.on('createBooking', (data) {
        Logger().d("SOCKET_TRACE createBooking: received");
        printPrettyJson(data);
        Logger().d("SOCKET_TRACE createBooking: dispatching to ${_listeners.length} listeners");
        _notifyListeners(data, 'createBooking');
        Logger().d("SOCKET_TRACE createBooking: dispatch complete");
      });
    } else {
      Logger().d("SOCKET_TRACE createBooking listener disabled for crash isolation");
    }

    socket?.on('driver_location_update', (data) {
      printPrettyJson("gdgdfgdfg-------"+data.toString());
      _notifyListeners(data, 'driver_location_update');
    });

    socket?.on('startNavigation', (data) {
      printPrettyJson(data);
      _notifyListeners(data, 'startNavigation');
    });

    socket?.on('users_chat_list_listener', (data) {
      printPrettyJson(data);
      _notifyListeners(data, 'users_chat_list_listener');
    });

    socket?.on('send_message_emit', (data) {
      printPrettyJson(data);
      _notifyListeners(data, 'send_message_emit');
    });

    socket?.on('user_constant_chat_list', (data) {
      Logger().d("Received user constant chat list: $data");
      _notifyListeners(data, 'users_chat_list_listener');
    });


  }

  void _notifyListeners(dynamic data, String eventType) {
    for (final listener in List<SocketListener>.from(_listeners)) {
      try {
        Logger().d("SOCKET_TRACE $eventType -> ${listener.runtimeType}");
        listener.onSocketEvent(data, eventType);
        Logger().d("SOCKET_TRACE $eventType <- ${listener.runtimeType}");
      } catch (e, stackTrace) {
        Logger().e(
          "Socket listener failed for $eventType",
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  void disconnectSocket() {
    socket?.disconnect();
  }

  void dispose() {
    disconnectSocket();
  }
}

abstract class SocketListener {
  void onSocketEvent(dynamic data, String eventType);
}
