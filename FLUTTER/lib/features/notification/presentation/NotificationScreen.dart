import 'package:fitness4life/features/notification/service/NotifyService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/notification/data/Notify.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  @override
  Widget build(BuildContext context) {
    // Lấy notifyService để quản lý thông báo
    final notifyService = Provider.of<NotifyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
      ),
      body: ListView.builder(
        itemCount: notifyService.notifies.length,
        itemBuilder: (context, index) {
          var notify = notifyService.notifies[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(notify.fullName[0]), // Hiển thị chữ cái đầu của fullName
              ),
              title: Text(notify.title),
              subtitle: Text(notify.content),
              trailing: Text(
                "${notify.createdDate.day}/${notify.createdDate.month}/${notify.createdDate.year}",
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                // Xử lý khi nhấn vào thông báo
                print('Tapped on notification ${notify.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
