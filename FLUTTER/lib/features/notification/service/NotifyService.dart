import 'package:fitness4life/api/Notification_Repository/NotifyRepository.dart';
import 'package:fitness4life/features/notification/data/Notify.dart';
import 'package:flutter/material.dart';

class NotifyService extends ChangeNotifier {
  final NotifyRepository _notifyRepository;
  List<Notify> notifies = [];
  int? notifyId;
  bool isLoading = false;
  String errorMessage = '';

  NotifyService(this._notifyRepository);

  Future<void> fetchNotifiesByUserId(int userId) async {
    isLoading = true;
    notifyListeners();
    try{
      notifies = await _notifyRepository.getNotifyByUserId(userId);
      print('Noties : $notifies');
      // Sau khi lấy dữ liệu, lưu vào SharedPreferences
      //saveGoalsToSharedPreferences();
    }
    catch(e) {
      print("Error fetching notify by userId: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Thêm thông báo mới vào danh sách thông báo
  void addNotification(Notify notify) {
    notifies.insert(0, notify); // Chèn thông báo mới vào đầu danh sách
    notifyListeners(); // Cập nhật giao diện
  }

  // Xử lý thông báo khi nhận từ Firebase (thêm vào danh sách)
  void handleFirebaseNotification(String title, String body) {
    // Tạo Notify từ dữ liệu nhận được từ Firebase
    var newNotify = Notify(
      id: DateTime.now().millisecondsSinceEpoch, // Tạo ID ngẫu nhiên hoặc dùng một giá trị duy nhất
      itemId: 0, // Cung cấp giá trị hợp lệ cho itemId
      userId: 1, // Cung cấp giá trị hợp lệ cho userId
      status: true, // Cung cấp giá trị hợp lệ cho status (có thể là 'unread', 'read', v.v.)
      deleteItem: false, // Cung cấp giá trị hợp lệ cho deleteItem
      title: title,
      content: body,
      createdDate: DateTime.now(),
      fullName: 'Quang Linh', // Có thể thay đổi nếu cần
    );

    addNotification(newNotify);
  }

}