import 'package:fitness4life/api/Notification_Repository/NotifyRepository2.dart';
import 'package:flutter/foundation.dart';

import '../data/NotifyModel.dart';

class NotifyService2 with ChangeNotifier {
  final NotifyRepository2 _repository;

  List<NotifyModel> _notifications = [];
  List<NotifyModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _error;

  NotifyService2(this._repository);

  List<NotifyModel> get notifications => _notifications;
  List<NotifyModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadNotifications.length;

  // Load all notifications for a user
  Future<void> loadNotifications(int userId) async {
    _isLoading = true;
    _error = null;

    try {
      final data = await _repository.getAllNotifications(userId);
      _notifications = data;
      print("📥 [NotifyService2] Tải xong ${data.length} thông báo");

      final unreadData = await _repository.getUnreadNotifications(userId);
      _unreadNotifications = unreadData;

    } catch (e) {
      _error = e.toString();
      print("❌ [NotifyService2] Lỗi tải thông báo: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();  // ✅ Chỉ gọi notifyListeners() 1 lần
    }
  }

  // Load only unread notifications
  Future<void> loadUnreadNotifications(int userId) async {
    try {
      final data = await _repository.getUnreadNotifications(userId);
      _unreadNotifications = data;
      notifyListeners();
    } catch (e) {
      print('Error loading unread notifications: $e');
    }
  }

  // Add a new notification (typically from WebSocket)
  void addNotification(NotifyModel notification) {
    // Add to the main list
    _notifications.insert(0, notification);

    // If unread, add to unread list
    if (!notification.status) {
      _unreadNotifications.insert(0, notification);
    }

    notifyListeners();
  }

  // Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);

      if (success) {
        // Update local lists
        for (int i = 0; i < _notifications.length; i++) {
          if (_notifications[i].id == notificationId) {
            final updatedNotification = NotifyModel(
              id: _notifications[i].id,
              itemId: _notifications[i].itemId,
              userId: _notifications[i].userId,
              fullName: _notifications[i].fullName,
              title: _notifications[i].title,
              createdDate: _notifications[i].createdDate,
              content: _notifications[i].content,
              status: true,  // Mark as read
              deleteItem: _notifications[i].deleteItem,
            );

            _notifications[i] = updatedNotification;
            break;
          }
        }

        // Remove from unread list
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final success = await _repository.deleteNotification(notificationId);

      if (success) {
        // Remove from both lists
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        notifyListeners();
      }

      return success;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}