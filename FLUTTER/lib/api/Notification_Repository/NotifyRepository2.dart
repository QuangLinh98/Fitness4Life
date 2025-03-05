import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import '../../features/notification/data/NotifyModel.dart';

class NotifyRepository2 {
  final ApiGateWayService _apiGateway;

  NotifyRepository2(this._apiGateway);

  // Get all notifications for the user
  Future<List<NotifyModel>> getAllNotifications(int userId) async {
    try {
      final response = await _apiGateway.getData('/notify/user/$userId');

      print('📡 [NotifyRepository2] API trả về: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotifyModel.fromJson(json)).toList();
      } else {
        throw Exception('❌ API trả về mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [NotifyRepository2] Lỗi khi lấy thông báo: $e');
      return [];
    }
  }

  // Get unread notifications for the user
  Future<List<NotifyModel>> getUnreadNotifications(int userId) async {
    try {
      final response = await _apiGateway.getData('/notify/user/$userId/unread');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotifyModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load unread notifications');
      }
    } catch (e) {
      print('Error getting unread notifications: $e');
      throw Exception('Failed to load unread notifications');
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiGateway.putData('/notify/read/$notificationId');
      return response?.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiGateway.deleteData('/notify/delete/$notificationId');
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}