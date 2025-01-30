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
