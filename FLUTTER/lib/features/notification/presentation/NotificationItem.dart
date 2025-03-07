// lib/features/notification/screens/components/notification_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../fitness_goal/presentation/screens/DashboardScreen.dart';
import '../../fitness_goal/presentation/screens/Goal/GoalScreen.dart';
import '../../smart_deal/presentation/screens/promotion/PromotionScreen.dart';
import '../data/NotifyModel.dart';


class NotificationItem extends StatelessWidget {
  final NotifyModel notification;
  final Function() onTap;
  final Function() onDismiss;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  // Hàm kiểm tra nội dung thông báo và điều hướng tương ứng
  void _handleNavigation(BuildContext context) {
    // Đánh dấu đã đọc
    onTap();

    // Lấy nội dung thông báo
    final String content = notification.content.toUpperCase();
    final String title = notification.title.toUpperCase();

    // Kiểm tra điều kiện điều hướng
    if (content.contains('POINT') ||
        content.contains('DIEM THUONG') ||
        title.contains('DIEM THUONG') ||
        title.contains('POINT')) {
      // Điều hướng đến màn hình Promotion
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PromotionScreen()),
      );
    }
    // Kiểm tra các mục tiêu fitness
    else if (content.contains('WEIGHT_LOSS') ||
        content.contains('GOAL') ||
        content.contains('FAT_LOSS') ||
        content.contains('WEIGHT_GAIN') ||
        content.contains('MUSCLE_GAIN') ||
        content.contains('MAINTENANCE')) {
      // Điều hướng đến màn hình Goal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(initialTabIndex: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    final formattedDate = dateFormat.format(notification.createdDate);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        // Thay đổi onTap để sử dụng hàm điều hướng
        onTap: () => _handleNavigation(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: notification.status ? Colors.white : Colors.blue.shade50,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification indicator dot
              if (!notification.status)
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.status ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}