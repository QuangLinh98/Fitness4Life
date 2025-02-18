
enum MetricName { WEIGHT, BODY_FAT, MUSCLEMASS}

class ProgressDTO {
  final int userId;
  final int? goal;
  final String trackingDate;
  final MetricName metricName;
  final double value;
  final double? weight;
  final double caloriesConsumed;
  final String? createdAt;

  ProgressDTO({
    required this.userId,
    required this.goal,
    required this.trackingDate,
    required this.metricName,
    required this.value,
    this.weight,
    required this.caloriesConsumed,
    this.createdAt,
  });

  // Chuyển đổi từ JSON sang Progress object
  factory ProgressDTO.fromJson(Map<String, dynamic> json) {
    return ProgressDTO(
      userId: json['userId'],
      goal: json['goal'],
      trackingDate: json['trackingDate'],
      metricName: MetricName.values.firstWhere(
            (e) => e.toString().split('.').last == json['metricName'],
        orElse: () => MetricName.WEIGHT,
      ),
      value: json['value'].toDouble(),
      weight: json['weight'] != null ? json['weight'].toDouble() : null,
      caloriesConsumed: json['caloriesConsumed'].toDouble(),
      createdAt: json['createdAt'] is List
          ? _formatDateTimeList(json['createdAt'])
          : json['createdAt'] ?? "",
    );
  }

  // Chuyển đổi từ Progress object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'goal': goal,
      'trackingDate': trackingDate,
      'metricName': metricName.toString().split('.').last,
      'value': value,
      'weight': weight,
      'caloriesConsumed': caloriesConsumed,
      'createdAt': createdAt,
    };
  }

  /// **Chuyển đổi `[YYYY, MM, DD]` thành `"YYYY-MM-DD"`**
  static String _formatDateList(List<dynamic> dateList) {
    if (dateList.length >= 3) {
      return "${dateList[0]}-${dateList[1].toString().padLeft(2, '0')}-${dateList[2].toString().padLeft(2, '0')}";
    }
    return "";
  }

  /// **Chuyển đổi `[YYYY, MM, DD, HH, MM, SS, MS]` thành `"YYYY-MM-DD HH:MM:SS"`**
  static String _formatDateTimeList(List<dynamic> dateTimeList) {
    if (dateTimeList.length >= 6) {
      return "${dateTimeList[0]}-${dateTimeList[1].toString().padLeft(2, '0')}-${dateTimeList[2].toString().padLeft(2, '0')} "
          "${dateTimeList[3].toString().padLeft(2, '0')}:${dateTimeList[4].toString().padLeft(2, '0')}:${dateTimeList[5].toString().padLeft(2, '0')}";
    }
    return "";
  }
}
