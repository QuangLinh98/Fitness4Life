// lib/features/notification/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fitness4life/features/notification/service/NotifyService2.dart';
import 'package:fitness4life/features/notification/service/WebSocketService.dart';
import 'package:fitness4life/token/token_manager.dart';
import '../data/NotifyModel.dart';

class NotificationProvider with ChangeNotifier {
  final NotifyService2 _notifyService;
  final WebSocketService _webSocketService;
  StreamSubscription? _notificationSubscription;
  bool _isInitialized = false;
  int? _userId;

  NotificationProvider(this._notifyService, this._webSocketService) {
    _initializeService();
  }

  // Getters
  List<NotifyModel> get notifications => _notifyService.notifications;
  List<NotifyModel> get unreadNotifications => _notifyService.unreadNotifications;
  bool get isLoading => _notifyService.isLoading;
  String? get error => _notifyService.error;
  int get unreadCount => _notifyService.unreadCount;
  bool get isInitialized => _isInitialized;

  // Khởi tạo service
  Future<void> _initializeService() async {
    print('🚀 [NotificationProvider] Đang khởi tạo...');
    try {
      _userId = await TokenManager.getUserId();
      print('👤 [NotificationProvider] UserId từ token: $_userId');

      if (_userId != null) {
        // Khởi tạo WebSocket
        print('🔌 [NotificationProvider] Khởi tạo WebSocket...');
        _webSocketService.initWebSocketConnection(_userId!);

        // Đăng ký lắng nghe thông báo từ WebSocket
        print('👂 [NotificationProvider] Đăng ký lắng nghe WebSocket...');
        _notificationSubscription?.cancel(); // Cancel any existing subscription first
        _notificationSubscription = _webSocketService.notificationStream.listen(_handleNewNotification);

        // Tải danh sách thông báo
        print('📥 [NotificationProvider] Tải danh sách thông báo...');
        await loadNotifications();

        _isInitialized = true;
        print('✅ [NotificationProvider] Khởi tạo hoàn tất');
      } else {
        print('⚠️ [NotificationProvider] Không tìm thấy userId trong token');
      }
    } catch (e, stackTrace) {
      print('❌ [NotificationProvider] Lỗi khi khởi tạo: $e');
      print('🔍 [NotificationProvider] Stack trace: $stackTrace');
    }
  }

  // Tải lại thông báo
  Future<void> loadNotifications() async {
    if (_userId == null) {
      print('⚠️ [NotificationProvider] Không thể tải thông báo: userId chưa được thiết lập');
      return;
    }

    print('🔄 [NotificationProvider] Đang tải thông báo...');
    await _notifyService.loadNotifications(_userId!);
    await _notifyService.loadUnreadNotifications(_userId!);
    print('✅ [NotificationProvider] Đã tải xong thông báo');

    // ✅ Thêm notifyListeners() để UI cập nhật
    notifyListeners();
  }

  // Xử lý thông báo mới từ WebSocket
  void _handleNewNotification(NotifyModel notification) {
    print('📩 [NotificationProvider] Nhận thông báo mới: ${notification.title}');

    // Đảm bảo thêm vào danh sách thông báo
    _notifyService.addNotification(notification);

    print('📃 [NotificationProvider] Tổng số thông báo hiện tại: ${notifications.length}');
    print('🔔 [NotificationProvider] Thông báo UI cập nhật');

    // Đảm bảo gọi notifyListeners() để cập nhật UI
    notifyListeners();
  }

  // Đánh dấu thông báo đã đọc
  Future<bool> markAsRead(int notificationId) async {
    print('📝 [NotificationProvider] Đánh dấu đã đọc: $notificationId');
    final success = await _notifyService.markAsRead(notificationId);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // Xóa thông báo
  Future<bool> deleteNotification(int notificationId) async {
    print('🗑️ [NotificationProvider] Xóa thông báo: $notificationId');
    final success = await _notifyService.deleteNotification(notificationId);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // Khởi tạo lại service (ví dụ: sau khi đăng nhập lại)
  Future<void> reinitialize() async {
    print('🔄 [NotificationProvider] Khởi tạo lại...');
    _isInitialized = false;
    await _initializeService();
  }

  @override
  void dispose() {
    print('🗑️ [NotificationProvider] Dọn dẹp tài nguyên...');
    _notificationSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
    print('✅ [NotificationProvider] Đã dọn dẹp xong');
  }
}