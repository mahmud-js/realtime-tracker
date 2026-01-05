import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/location_data.dart';

class WebSocketProvider extends ChangeNotifier {
  late WebSocketChannel _channel;
  String userId = '';
  final List<LocationData> connectedUsers = [];
  bool isConnected = false;
  String connectionStatus = 'Disconnected';

  WebSocketProvider() {
    userId = 'User-${const Uuid().v4().substring(0, 8)}';
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    try {
      // Connect to your Go server
      final wsUrl = Uri.parse('ws://localhost:8080/ws');
      _channel = WebSocketChannel.connect(wsUrl);
      
      isConnected = true;
      connectionStatus = 'Connected ✅';
      notifyListeners();

      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleClose(),
      );
    } catch (e) {
      connectionStatus = 'Connection Error ❌';
      isConnected = false;
      notifyListeners();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message);
      final location = LocationData.fromJson(json);
      
      // Update or add user location
      final index = connectedUsers.indexWhere((u) => u.id == location.id);
      if (index >= 0) {
        connectedUsers[index] = location;
      } else {
        connectedUsers.add(location);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _handleError(dynamic error) {
    connectionStatus = 'Connection Error ❌';
    isConnected = false;
    notifyListeners();
  }

  void _handleClose() {
    connectionStatus = 'Disconnected';
    isConnected = false;
    notifyListeners();
    
    // Attempt to reconnect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _initializeWebSocket();
    });
  }

  void sendLocation(LocationData location) {
    if (_channel.closeCode == null) {
      _channel.sink.add(jsonEncode(location.toJson()));
    }
  }

  int get userCount => connectedUsers.length;

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
