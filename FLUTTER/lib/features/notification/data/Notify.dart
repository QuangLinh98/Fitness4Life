
class Notify {
  final int id;
  final int itemId;
  final int userId;
  final String fullName;
  final String title;
  final DateTime createdDate;
  final String content;
  final bool status;
  final bool deleteItem;

  // Constructor
  Notify({
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

  // Hàm factory để tạo đối tượng từ JSON
  factory Notify.fromJson(Map<String, dynamic> json) {
    return Notify(
      id: json['id'],
      itemId: json['itemId'],
      userId: json['userId'],
      fullName: json['fullName'],
      title: json['title'],
      createdDate: DateTime.parse(json['createdDate']),
      content: json['content'],
      status: json['status'],
      deleteItem: json['deleteItem'],
    );
  }

  // Hàm để chuyển đối tượng thành JSON
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
}
