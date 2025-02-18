import 'package:intl/intl.dart';

class PromotionOfUserDTO {
  final int id;
  final int userId;
  final String title;
  final String description;
  final double discountValue;
  final List<String> discountType;
  final List<String> applicableService;
  final List<String> customerType;
  final List<String> packageName;
  final double minValue;
  final String code;
  final int promotionAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isUsed;
  final String createdBy;

  PromotionOfUserDTO({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.applicableService,
    required this.customerType,
    required this.packageName,
    required this.minValue,
    required this.code,
    required this.promotionAmount,
    required this.startDate,
    required this.endDate,
    required this.isUsed,
    required this.createdBy,
  });
  factory PromotionOfUserDTO.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return PromotionOfUserDTO(
      id: json['id'],
      userId: json['userId'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      discountType: List<String>.from(json['discountType'] ?? []),
      applicableService: List<String>.from(json['applicableService'] ?? []),
      customerType: json['customerType'] != null ? List<String>.from(json['customerType']) : [],
      packageName: json['packageName'] != null ? List<String>.from(json['packageName']) : [],
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      code: json['code'] ?? '',
      promotionAmount: json['promotionAmount'] ?? 0,
      startDate: json['startDate'] != null ? dateFormat.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? dateFormat.parse(json['endDate']) : DateTime.now(),
      isUsed: json['isUsed'] ?? false,
      createdBy: json['createdBy'] ?? 'Unknown',
    );
  }
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'discountValue': discountValue,
      'discountType': discountType,
      'applicableService': applicableService,
      'customerType': customerType,
      'packageName': packageName,
      'minValue': minValue,
      'code': code,
      'promotionAmount': promotionAmount,
      'startDate': dateFormat.format(startDate),
      'endDate': dateFormat.format(endDate),
      'isUsed': isUsed,
      'createdBy': createdBy,
    };
  }
}
