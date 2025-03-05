
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompService {
  StompClient? stompClient;

  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'http://172.16.12.72:9001/ws', // Địa chỉ WebSocket backend
        onConnect: (StompFrame frame) {
          print('Connected to WebSocket');

          // Lắng nghe tin nhắn từ server
          stompClient!.subscribe(
            destination: '/topic/notifications',
            callback: (StompFrame frame) {
              print('Received: ${frame.body}');
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
      ),
    );

    stompClient!.activate();
  }

  void sendMessage(String message) {
    stompClient?.send(
      destination: '/app/send-notification', // Điểm đến server xử lý
      body: message,
    );
  }

  void disconnect() {
    stompClient?.deactivate();
  }
}