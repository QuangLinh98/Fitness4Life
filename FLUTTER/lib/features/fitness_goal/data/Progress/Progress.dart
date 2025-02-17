class Progress {
  int? id;
  int? userId;
  String? fullName;
  int? goalId;
  DateTime? trackingDate;
  MetricName? metricName;
  double? value;
  double? weight;
  double caloriesConsumed;
  String? message;
  DateTime? createdAt;
  DateTime? updatedAt;

  Progress({
    this.id,
    this.userId,
    this.fullName,
    this.goalId,
    this.trackingDate,
    this.metricName,
    this.value,
    this.weight,
    required this.caloriesConsumed,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  /// **Chuyển đổi từ JSON sang Object**
  factory Progress.fromJson(Map<String, dynamic> json) {

    return Progress(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      goalId: json['goalId'],
      trackingDate: _parseLocalDate(json['trackingDate']),
      metricName: _parseMetricName(json['metricName']),
      value: json['value']?.toDouble(),
      weight: json['weight']?.toDouble(),
      caloriesConsumed: json['caloriesConsumed'].toDouble(),
      message: json['message'],
      createdAt: _parseLocalDateTime(json['createdAt']),
      updatedAt: _parseLocalDateTime(json['updatedAt']),
    );
  }

  /// **Chuyển đổi từ Object sang JSON**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'goalId': goalId,
      'trackingDate': trackingDate != null
          ? [trackingDate!.year, trackingDate!.month, trackingDate!.day]
          : null,
      'metricName': metricName?.name,
      'value': value,
      'weight': weight,
      'caloriesConsumed': caloriesConsumed,
      'message': message,
      'createdAt': createdAt != null
          ? [
        createdAt!.year,
        createdAt!.month,
        createdAt!.day,
        createdAt!.hour,
        createdAt!.minute,
        createdAt!.second,
        createdAt!.millisecond * 1000000, // Milliseconds -> Nanoseconds
      ]
          : null,
      'updatedAt': updatedAt != null
          ? [
        updatedAt!.year,
        updatedAt!.month,
        updatedAt!.day,
        updatedAt!.hour,
        updatedAt!.minute,
        updatedAt!.second,
        updatedAt!.millisecond * 1000000, // Milliseconds -> Nanoseconds
      ]
          : null,
    };
  }

  /// **Hàm parse LocalDate từ JSON (dạng List<int>)**
  static DateTime? _parseLocalDate(dynamic localDate) {
    if (localDate == null) return null;

    // Nếu dữ liệu là List<int>, parse bình thường
    if (localDate is List && localDate.length >= 3) {
      return DateTime(localDate[0], localDate[1], localDate[2]);
    }

    // Nếu dữ liệu là String (ví dụ: "2024-12-02"), parse từ chuỗi
    if (localDate is String) {
      try {
        return DateTime.parse(localDate);
      } catch (e) {
        print("Error parsing trackingDate: $e");
        return null;
      }
    }

    print("Invalid trackingDate format: $localDate");
    return null;
  }

  /// **Hàm parse LocalDateTime từ JSON (dạng List<int>)**
  static DateTime? _parseLocalDateTime(dynamic localDateTime) {
    if (localDateTime == null) return null;

    // Nếu dữ liệu là List<int>, parse bình thường
    if (localDateTime is List && localDateTime.length >= 6) {
      return DateTime(
        localDateTime[0],
        localDateTime[1],
        localDateTime[2],
        localDateTime[3],
        localDateTime[4],
        localDateTime[5],
        (localDateTime.length > 6 ? localDateTime[6] ~/ 1000000 : 0),
      );
    }

    // Nếu dữ liệu là String (ví dụ: "2024-12-07T00:40:08Z"), parse từ chuỗi
    if (localDateTime is String) {
      try {
        return DateTime.parse(localDateTime);
      } catch (e) {
        print("Error parsing createdAt: $e");
        return null;
      }
    }

    print("Invalid createdAt format: $localDateTime");
    return null;
  }

  /// **Hàm parse MetricName từ JSON**
  static MetricName? _parseMetricName(String? metric) {
    if (metric == null) return MetricName.WEIGHT;
    try {
      return MetricName.values.firstWhere((e) => e.name == metric);
    } catch (e) {
      return MetricName.WEIGHT;
    }
  }

  /// **Phương thức trả về giá trị của chỉ số dựa trên metricName**
  double? getValueByMetric() {
    switch (metricName) {
      case MetricName.WEIGHT:
        return weight;
      case MetricName.BODY_FAT:
      case MetricName.MUSCLEMASS:
        return value;
      default:
        return null;
    }
  }
}

/// **Enum MetricName để ánh xạ với backend**
enum MetricName { WEIGHT, BODY_FAT, MUSCLEMASS }
