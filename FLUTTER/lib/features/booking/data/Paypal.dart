import 'dart:convert';

enum PayMethodType { PAYPAL, CREDIT_CARD, BANK_TRANSFER }
enum PayStatusType { PENDING, COMPLETED, CANCELED, FAILED }
enum PackageName { BASIC, STANDARD, PREMIUM, ROYAL }

class Paypal {
  final int id;
  final int userId;
  final String fullName;
  final int packageId;
  final String paymentId;
  final String payerId;
  final String description;
  final DateTime buyDate;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final PayMethodType payMethodType;
  final PayStatusType payStatusType;
  final PackageName packageName;
  final String approvalUrl;

  Paypal({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.packageId,
    required this.paymentId,
    required this.payerId,
    required this.description,
    required this.buyDate,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.payMethodType,
    required this.payStatusType,
    required this.packageName,
    required this.approvalUrl,
  });

  // Chuyển đổi từ JSON sang Object
  factory Paypal.fromJson(Map<String, dynamic> json) {
    return Paypal(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      packageId: json['packageId'],
      paymentId: json['paymentId'],
      payerId: json['payerId'],
      description: json['description'],
      buyDate: DateTime.parse(json['buyDate']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalAmount: json['totalAmount'].toDouble(),
      payMethodType: PayMethodType.values.firstWhere(
              (e) => e.toString().split('.').last == json['payMethodType']),
      payStatusType: PayStatusType.values.firstWhere(
              (e) => e.toString().split('.').last == json['payStatusType']),
      packageName: PackageName.values.firstWhere(
              (e) => e.toString().split('.').last == json['packageName']),
      approvalUrl: json['approvalUrl'] ?? "",
    );
  }
}
