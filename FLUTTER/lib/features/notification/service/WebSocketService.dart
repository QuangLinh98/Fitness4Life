import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../data/NotifyModel.dart';

class WebSocketService {
  StompClient? _stompClient;
  final StreamController<NotifyModel> _notificationController = StreamController<NotifyModel>.broadcast();
  Stream<NotifyModel> get notificationStream => _notificationController.stream;
  bool _isConnected = false;
  int? _currentUserId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  // Khởi tạo và kết nối đến WebSocket
  void initWebSocketConnection(int userId) {
    print('🚀 [WebSocket] Bắt đầu kết nối WebSocket cho userId: $userId');
    _currentUserId = userId;
    _reconnectAttempts = 0;

    // Đóng kết nối cũ nếu có
    if (_stompClient != null && _isConnected) {
      print('🔄 [WebSocket] Đóng kết nối cũ trước khi tạo kết nối mới');
      disconnect();
    }

    // Hủy timer reconnect nếu đang có
    _reconnectTimer?.cancel();

    // Sử dụng địa chỉ máy chủ - CÓ THỂ CẦN PHẢI THAY ĐỔI
    final String url = isRunningOnEmulator()
        ? 'http://10.0.2.2:8083/ws'  // Cho emulator
        : 'http://172.16.12.3:8083/ws'; // URL gốc - thay đổi nếu cần

    print('🔌 [WebSocket] Đang kết nối đến: $url');

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: url,
        heartbeatOutgoing: Duration(seconds: 30),
        heartbeatIncoming: Duration(seconds: 30),
        connectionTimeout: Duration(seconds: 60), // Tăng timeout lên 60 giây
        onConnect: (StompFrame frame) {
          print('✅ [WebSocket] Kết nối thành công: ${frame.body}');

          _isConnected = true;
          _reconnectAttempts = 0;  // Reset số lần thử kết nối
          print('✅ [WebSocket] Kết nối thành công');

          // Đăng ký nhận thông báo cho người dùng cụ thể
          final destination = '/user/$userId/queue/notifications';
          print('📩 [WebSocket] Đăng ký nhận thông báo tại: $destination');

          _stompClient!.subscribe(
            destination: destination,
            callback: _onNotificationReceived,
          );

          print('✅ [WebSocket] Đã đăng ký kênh thành công');
        },
        onWebSocketError: (dynamic error) {
          print('❌ [WebSocket] Lỗi kết nối: $error');
          _isConnected = false;
          _attemptReconnect();
        },
        onDisconnect: (dynamic frame) {
          print('⚠️ [WebSocket] Ngắt kết nối');
          _isConnected = false;
          _attemptReconnect();
        },
        onStompError: (dynamic frame) {
          print('❌ [WebSocket] Lỗi STOMP: ${frame?.body ?? "Unknown error"}');
          _attemptReconnect();
        },
        onDebugMessage: (String message) {
          if (kDebugMode) {
            print('🔍 [WebSocket] Debug: $message');
          }
        },
      ),
    );

    print('🔄 [WebSocket] Kích hoạt kết nối...');
    try {
      _stompClient!.activate();
    } catch (e) {
      print('❌ [WebSocket] Lỗi khi kích hoạt kết nối: $e');
      _attemptReconnect();
    }
  }
  // Kiểm tra xem ứng dụng có đang chạy trên máy ảo/emulator không
  bool isRunningOnEmulator() {
    // Logic đơn giản: nếu đang chạy trên Android emulator,
    // Bạn có thể cần điều chỉnh logic này dựa trên cách bạn phát hiện emulator
    bool isEmulator = false;

    // Thêm logic phát hiện emulator ở đây
    // Ví dụ cho Android (sẽ cần phải mở rộng):
    // final String androidId = /* lấy Android ID */;
    // isEmulator = androidId == '000000000000000';

    return isEmulator;
  }

  // Thử kết nối lại khi mất kết nối
  void _attemptReconnect() {
    if (!_isConnected && _currentUserId != null && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;

      // Tăng thời gian chờ sau mỗi lần thử lại (exponential backoff)
      final int delaySeconds = _reconnectAttempts * 5;

      print('🔄 [WebSocket] Thử kết nối lại lần $_reconnectAttempts/$_maxReconnectAttempts sau $delaySeconds giây...');

      _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        print('🔄 [WebSocket] Đang kết nối lại...');
        initWebSocketConnection(_currentUserId!);
      });
    }  else if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('⛔ [WebSocket] Không thể kết nối lại, sẽ thử lại sau 10 giây...');
      _reconnectTimer = Timer(Duration(seconds: 10), () {
        _reconnectAttempts = 0; // Reset lại số lần thử
        initWebSocketConnection(_currentUserId!);
      });
    }
  }

  // Xử lý khi nhận thông báo từ WebSocket
  void _onNotificationReceived(StompFrame frame) {
    try {
      if (frame.body != null) {
        print('📥 [WebSocket] Nhận được thông báo mới');
        print('📦 [WebSocket] Nội dung thông báo: ${frame.body}');

        final Map<String, dynamic> message = json.decode(frame.body!);
        final NotifyModel notification = NotifyModel.fromJson(message);

        print('✅ [WebSocket] Đã chuyển đổi thành công thành NotifyModel');
        print('📝 [WebSocket] Tiêu đề: ${notification.title}');
        print('📝 [WebSocket] Nội dung: ${notification.content}');

        _notificationController.add(notification);
      } else {
        print('⚠️ [WebSocket] Nhận được thông báo rỗng');
      }
    } catch (e, stackTrace) {
      print('❌ [WebSocket] Lỗi khi xử lý thông báo: $e');
      print('🔍 [WebSocket] Stack trace: $stackTrace');
      print('📦 [WebSocket] Thông báo gốc: ${frame.body}');
    }
  }

  // Ngắt kết nối WebSocket
  void disconnect() {
    _reconnectTimer?.cancel(); // Hủy timer reconnect
    if (_stompClient != null) {
      print('👋 [WebSocket] Đang ngắt kết nối...');
      try {
        _stompClient!.deactivate();
        _isConnected = false;
        print('✅ [WebSocket] Đã ngắt kết nối thành công');
      } catch (e) {
        print('⚠️ [WebSocket] Lỗi khi ngắt kết nối: $e');
      }
    }
  }

  // Kết nối lại thủ công (gọi từ UI)
  void manualReconnect(int userId) {
    print('🔄 [WebSocket] Kết nối lại thủ công cho userId: $userId');
    _reconnectAttempts = 0; // Reset số lần thử kết nối
    initWebSocketConnection(userId);
  }

  // Kiểm tra xem kết nối có đang hoạt động không
  bool get isConnected => _isConnected;

  // Đóng tài nguyên khi service bị hủy
  void dispose() {
    print('🗑️ [WebSocket] Đang dọn dẹp tài nguyên...');
    _reconnectTimer?.cancel();
    disconnect();
    _notificationController.close();
    print('✅ [WebSocket] Đã dọn dẹp xong');
  }
}