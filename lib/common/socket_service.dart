import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../network/api_constants.dart';
import 'apputills.dart';
import 'db_helper.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;
  IO.Socket? socket;
  final List<SocketListener> _listeners = [];
  Function(dynamic data,String eventType)? onListener;

  SocketService._internal() {
    connectToServer();
  }

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
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'update_route_listener');
      }
    });

    socket?.on('manager_route_listener', (data) {
      printPrettyJson(data);
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'manager_route_listener');
      }
    });

    socket?.on('loction_update', (data) {
      printPrettyJson(data);
      Logger().d("location updated successfully");
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'loction_update');
      }
    });

    socket?.on('createBooking', (data) {
      printPrettyJson(data);
      Logger().d("sfsdfsdds");
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'createBooking');
      }
    });

    socket?.on('driver_location_update', (data) {
      printPrettyJson(data);
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'driver_location_update');
      }
    });

    socket?.on('startNavigation', (data) {
      printPrettyJson(data);
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'startNavigation');
      }
    });

    socket?.on('users_chat_list_listener', (data) {
      printPrettyJson(data);
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'users_chat_list_listener');
      }
    });

    socket?.on('send_message_emit', (data) {
      printPrettyJson(data);
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'send_message_emit');
      }
    });

    socket?.on('user_constant_chat_list', (data) {
      Logger().d("Received user constant chat list: $data");
      for (var listener in _listeners) {
        listener.onSocketEvent(data, 'users_chat_list_listener');
      }
    });


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
