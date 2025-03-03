
enum ServiceBranch { GYM, YOGA, GROUPX, DANCE, TUMS, CYCLING }

class Branch {
  final int id;
  final String branchName;
  final String slug;
  final String address;
  final String phoneNumber;
  final String email;
  final String openHours; // Giữ nguyên nhưng sẽ convert từ List<int>
  final String closeHours; // Giữ nguyên nhưng sẽ convert từ List<int>
  final List<ServiceBranch> services;
  final DateTime createAt;
  final DateTime? updateAt; // Cho phép null

  Branch({
    required this.id,
    required this.branchName,
    required this.slug,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.openHours,
    required this.closeHours,
    required this.services,
    required this.createAt,
    this.updateAt, // Cho phép null
  });

  /// Chuyển đổi từ JSON thành `Branch`
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      branchName: json['branchName'],
      slug: json['slug'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],

      /// 🛠 Convert List<int> thành String giờ mở cửa
      openHours: (json['openHours'] as List).join(":"), // e.g., [6, 0] -> "6:00"
      closeHours: (json['closeHours'] as List).join(":"), // e.g., [22, 0] -> "22:00"

      /// 🛠 Convert List<String> thành danh sách `ServiceBranch`
      services: (json['services'] as List)
          .map((e) => ServiceBranch.values.firstWhere((s) => s.toString().split('.').last == e))
          .toList(),

      /// 🛠 Convert List<int> thành DateTime
      createAt: DateTime(
        json['createAt'][0], // Year
        json['createAt'][1], // Month
        json['createAt'][2], // Day
        json['createAt'][3], // Hour
        json['createAt'][4], // Minute
        json['createAt'][5], // Second
      ),

      /// 🛠 Xử lý `updateAt` có thể là null
      updateAt: json['updateAt'] != null
          ? DateTime(
        json['updateAt'][0],
        json['updateAt'][1],
        json['updateAt'][2],
        json['updateAt'][3],
        json['updateAt'][4],
        json['updateAt'][5],
      )
          : null,
    );
  }

  /// Chuyển đổi từ `Branch` thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchName': branchName,
      'slug': slug,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,

      /// 🛠 Convert giờ từ String thành List<int>
      'openHours': openHours.split(":").map((e) => int.parse(e)).toList(),
      'closeHours': closeHours.split(":").map((e) => int.parse(e)).toList(),

      /// 🛠 Convert danh sách `ServiceBranch` thành List<String>
      'services': services.map((e) => e.toString().split('.').last).toList(),

      /// 🛠 Convert DateTime thành List<int>
      'createAt': [createAt.year, createAt.month, createAt.day, createAt.hour, createAt.minute, createAt.second],

      /// 🛠 Nếu updateAt != null, convert sang List<int>, nếu null thì gửi null
      'updateAt': updateAt != null
          ? [updateAt!.year, updateAt!.month, updateAt!.day, updateAt!.hour, updateAt!.minute, updateAt!.second]
          : null,

    };
  }
}
