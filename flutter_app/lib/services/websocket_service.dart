import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/location_data.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String url;
  final Function(LocationData) onMessageReceived;
  final Function() onConnected;
  final Function() onDisconnected;
  final Function(dynamic) onError;

  WebSocketService({
    required this.url,
    required this.onMessageReceived,
    required this.onConnected,
    required this.onDisconnected,
    required this.onError,
  });

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      onConnected();
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message as String);
          onMessageReceived(LocationData.fromJson(data));
        },
        onDone: () {
          onDisconnected();
        },
        onError: (error) {
          onError(error);
        },
      );
    } catch (e) {
      onError(e);
    }
  }

  void sendLocation(LocationData data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data.toJson()));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
