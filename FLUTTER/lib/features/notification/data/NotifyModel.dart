// lib/features/notification/models/notify_model.dart
class NotifyModel {
  final int id;
  final int itemId;
  final int userId;
  final String fullName;
  final String title;
  final DateTime createdDate;
  final String content;
  final bool status; // read/unread status
  final bool deleteItem;

  NotifyModel({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.fullName,
    required this.title,
    required this.createdDate,
    required this.content,
    required this.status,
    required this.deleteItem,
  });

  factory NotifyModel.fromJson(Map<String, dynamic> json) {
    return NotifyModel(
      id: json['id'],
      itemId: json['itemId'],
      userId: json['userId'],
      fullName: json['fullName'] ?? '',
      title: json['title'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      content: json['content'] ?? '',
      status: json['status'] ?? false,
      deleteItem: json['deleteItem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'userId': userId,
      'fullName': fullName,
      'title': title,
      'createdDate': createdDate.toIso8601String(),
      'content': content,
      'status': status,
      'deleteItem': deleteItem,
    };
  }
  @override
  String toString() {
    return 'NotifyModel(id: $id, title: $title, content: $content, status: $status)';
  }
}