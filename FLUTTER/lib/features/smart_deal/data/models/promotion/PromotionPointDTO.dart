class PromotionPointDTO {
  String id;
  String title;
  String description;
  List<String> discountType;
  double discountValue;
  DateTime? startDate;
  DateTime? endDate;
  bool isActive;
  List<String> applicableService;
  double minValue;
  List<String> customerType;
  String createdBy;
  List<String> packageName;
  String code;
  int points;

  PromotionPointDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.applicableService,
    required this.minValue,
    required this.customerType,
    required this.createdBy,
    required this.packageName,
    required this.code,
    required this.points,
  });

  factory PromotionPointDTO.fromJson(Map<String, dynamic> json) {
    return PromotionPointDTO(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      discountType: List<String>.from(json['discountType'] ?? []),
      discountValue: (json['discountValue'] as num).toDouble(),
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
      applicableService: List<String>.from(json['applicableService'] ?? []),
      minValue: (json['minValue'] as num).toDouble(),
      customerType: List<String>.from(json['customerType'] ?? []),
      createdBy: json['createdBy'],
      packageName: List<String>.from(json['packageName'] ?? []),
      code: json['code'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'startDate': startDate?.toIso8601String(), // Trả về null nếu startDate null
      'endDate': endDate?.toIso8601String(), // Trả về null nếu endDate null
      'isActive': isActive,
      'applicableService': applicableService,
      'minValue': minValue,
      'customerType': customerType,
      'createdBy': createdBy,
      'packageName': packageName,
      'code': code,
      'points': points,
    };
  }
}
