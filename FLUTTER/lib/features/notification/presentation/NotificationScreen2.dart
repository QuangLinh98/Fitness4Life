// lib/features/notification/screens/notification_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/NotificationProvider.dart';
import 'NotificationItem.dart';
import 'NotificationEmpty.dart';

class NotificationScreen2 extends StatefulWidget {
  const NotificationScreen2({Key? key}) : super(key: key);

  @override
  State<NotificationScreen2> createState() => _NotificationScreen2State();
}

class _NotificationScreen2State extends State<NotificationScreen2> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách thông báo khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.loadNotifications(); // ✅ Luôn tải thông báo thay vì kiểm tra isInitialized
      }
    });
    // Set up periodic refresh
    Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) { // Check if widget is still in the tree
        final provider = Provider.of<NotificationProvider>(context, listen: false);
        provider.loadNotifications();
      } else {
        timer.cancel(); // Cancel timer if widget is disposed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          print("🔄 [UI] Cập nhật danh sách thông báo: ${provider.notifications.length}");

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Đã xảy ra lỗi: ${provider.error}', style: TextStyle(color: Colors.red)));
          }
          if (provider.notifications.isEmpty) {
            return const NotificationEmpty();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () async {
                    // Đánh dấu thông báo đã đọc khi nhấn vào
                    if (!notification.status) {
                      await provider.markAsRead(notification.id);
                    }
                    // Xử lý hành động khi nhấn vào thông báo (nếu cần)
                  },
                  onDismiss: () async {
                    // Xóa thông báo khi vuốt
                    await provider.deleteNotification(notification.id);
                    provider.loadNotifications();  // 🔥 Cập nhật danh sách ngay sau khi xóa

                    // Hiển thị Snackbar thông báo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã xóa thông báo'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () {
                            // Có thể thêm chức năng hoàn tác ở đây
                            provider.loadNotifications();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}