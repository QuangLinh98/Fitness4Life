// import 'dart:convert';
//
// class UserPromotion {
//   final int id;
//   final int userId;
//   final String promotionCode;
//   final int promotionAmount;
//   final bool isUsed;
//   final DateTime startDate;
//   final DateTime endDate;
//
//   UserPromotion({
//     required this.id,
//     required this.userId,
//     required this.promotionCode,
//     required this.promotionAmount,
//     required this.isUsed,
//     required this.startDate,
//     required this.endDate,
//   });
//
//   // Chuyển từ JSON thành Object
//   factory UserPromotion.fromJson(Map<String, dynamic> json) {
//     return UserPromotion(
//       id: json['id'],
//       userId: json['userId'],
//       promotionCode: json['promotionCode'],
//       promotionAmount: json['promotionAmount'],
//       isUsed: json['isUsed'],
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//     );
//   }
//
//   // Chuyển từ Object thành JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'promotionCode': promotionCode,
//       'promotionAmount': promotionAmount,
//       'isUsed': isUsed,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//     };
//   }
//
//   // Chuyển từ JSON String thành Object
//   static UserPromotion fromJsonString(String jsonString) {
//     final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//     return UserPromotion.fromJson(jsonData);
//   }
//
//   // Chuyển từ Object thành JSON String
//   String toJsonString() {
//     return jsonEncode(toJson());
//   }
// }
