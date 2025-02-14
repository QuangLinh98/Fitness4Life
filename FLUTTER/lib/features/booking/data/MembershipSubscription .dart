import 'package:intl/intl.dart';

class MembershipSubscription {
  final int userId;
  final DateTime transactionDate;
  final String description;
  final String paymentMethod;
  final String status;
  final String transactionId;
  final String paymentId;
  final DateTime expirationDate;
  final double amount;
  final String membershipLevel;
  final String userName;

  MembershipSubscription({
    required this.userId,
    required this.transactionDate,
    required this.description,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.paymentId,
    required this.expirationDate,
    required this.amount,
    required this.membershipLevel,
    required this.userName,
  });

  factory MembershipSubscription.fromJson(Map<String, dynamic> json) {
    return MembershipSubscription(
      userId: json['userId'],
      transactionDate: DateTime(
        json['buyDate'][0],
        json['buyDate'][1],
        json['buyDate'][2],
      ),
      description: json['description'],
      paymentMethod: json['payMethodType'],
      status: json['payStatusType'],
      transactionId: json['payerId'],
      paymentId: json['paymentId'],
      expirationDate: DateTime(
        json['endDate'][0],
        json['endDate'][1],
        json['endDate'][2],
      ),
      amount: json['totalAmount'],
      membershipLevel: json['packageName'],
      userName: json['fullName'],
    );
  }

  /// ✅ **Hàm format ngày tháng**
  String get formattedTransactionDate => DateFormat('dd/MM/yyyy').format(transactionDate);
  String get formattedExpirationDate => DateFormat('dd/MM/yyyy').format(expirationDate);

  @override
  String toString() {
    return 'MembershipSubscription(userId: $userId, transactionDate: $formattedTransactionDate, paymentMethod: $paymentMethod, status: $status, transactionId: $transactionId, paymentId: $paymentId, expirationDate: $formattedExpirationDate, amount: $amount, membershipLevel: $membershipLevel, userName: $userName)';
  }
}

// import 'dart:convert';
//
// enum PayMethodType { PAYPAL, CREDIT_CARD, BANK_TRANSFER }
// enum PayStatusType { PENDING, COMPLETED, FAILED }
// enum PackageName { BASIC, STANDARD, PREMIUM }
//
// class MembershipSubscription {
//   final int id;
//   final int userId;
//   final String fullName;
//   final int packageId;
//   final String paymentId;
//   final String payerId;
//   final String description;
//   final DateTime buyDate;
//   final DateTime startDate;
//   final DateTime endDate;
//   final double totalAmount;
//   final PayMethodType payMethodType;
//   final PayStatusType payStatusType;
//   final PackageName packageName;
//
//   MembershipSubscription({
//     required this.id,
//     required this.userId,
//     required this.fullName,
//     required this.packageId,
//     required this.paymentId,
//     required this.payerId,
//     required this.description,
//     required this.buyDate,
//     required this.startDate,
//     required this.endDate,
//     required this.totalAmount,
//     required this.payMethodType,
//     required this.payStatusType,
//     required this.packageName,
//   });
//
//   // Chuyển đổi từ JSON sang Object
//   factory MembershipSubscription.fromJson(Map<String, dynamic> json) {
//     List<int> buyDateList = json['buyDate'];
//     List<int> startDateList = json['startDate'];
//     List<int> endDateList = json['endDate'];
//
//     return MembershipSubscription(
//       id: json['id'],
//       userId: json['userId'],
//       fullName: json['fullName'],
//       packageId: json['packageId'],
//       paymentId: json['paymentId'],
//       payerId: json['payerId'],
//       description: json['description'],
//       buyDate: DateTime(
//         buyDateList[0],
//         buyDateList[1],
//         buyDateList[2],
//         buyDateList.length > 3 ? buyDateList[3] : 0,
//         buyDateList.length > 4 ? buyDateList[4] : 0,
//         buyDateList.length > 5 ? buyDateList[5] : 0,
//       ),
//       startDate: DateTime(startDateList[0], startDateList[1], startDateList[2]),
//       endDate: DateTime(endDateList[0], endDateList[1], endDateList[2]),
//       totalAmount: (json['totalAmount'] ?? 0).toDouble(),
//       payMethodType: PayMethodType.values.firstWhere(
//             (e) => e.toString().split('.').last == json['payMethodType'],
//         orElse: () => PayMethodType.PAYPAL,
//       ),
//       payStatusType: PayStatusType.values.firstWhere(
//             (e) => e.toString().split('.').last == json['payStatusType'],
//         orElse: () => PayStatusType.PENDING,
//       ),
//       packageName: PackageName.values.firstWhere(
//             (e) => e.toString().split('.').last == json['packageName'],
//         orElse: () => PackageName.BASIC,
//       ),
//     );
//   }
//
//
//   // Chuyển đổi từ Object sang JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'fullName': fullName,
//       'packageId': packageId,
//       'paymentId': paymentId,
//       'payerId': payerId,
//       'description': description,
//       'buyDate': buyDate.toIso8601String(),
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'totalAmount': totalAmount,
//       'payMethodType': payMethodType.toString().split('.').last,
//       'payStatusType': payStatusType.toString().split('.').last,
//       'packageName': packageName.toString().split('.').last,
//     };
//   }
//
//     /// ✅ **Hàm format ngày tháng**
//   String get formattedTransactionDate => DateFormat('dd/MM/yyyy').format(startDate);
//   String get formattedExpirationDate => DateFormat('dd/MM/yyyy').format(endDate);
//
//   // Chuyển đổi danh sách từ JSON sang List Object
//   static List<MembershipSubscription> fromJsonList(List<dynamic> jsonList) {
//     return jsonList.map((json) => MembershipSubscription.fromJson(json)).toList();
//   }
// }

