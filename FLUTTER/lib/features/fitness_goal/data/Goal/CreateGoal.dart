import 'package:intl/intl.dart';

enum GoalType { WEIGHT_LOSS , WEIGHT_GAIN, MUSCLE_GAIN, FAT_LOSS, MAINTENANCE } // Các giá trị GoalType
//enum GoalStatus { PENDING, COMPLETED, IN_PROGRESS } // Các giá trị GoalStatus
enum ActivityLevel { SEDENTARY, LIGHTLY_ACTIVE, MODERATELY_ACTIVE, VERY_ACTIVE, EXTREMELY_ACTIVE } // Các giá trị ActivityLevel

class GoalDTO {
  final int userId;
  final GoalType goalType;
  final double targetValue;
  final double currentValue;
  final double? weight;
  final DateTime startDate;
  final DateTime endDate;
  //final GoalStatus? goalStatus;
  final ActivityLevel activityLevel;
  //final DateTime createdAt;

  GoalDTO({
    required this.userId,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    this.weight,
    required this.startDate,
    required this.endDate,
    //this.goalStatus,
    required this.activityLevel,
    //required this.createdAt,
  });

  // Phương thức chuyển đổi từ JSON thành GoalDTO
  factory GoalDTO.fromJson(Map<String, dynamic> json) {
    return GoalDTO(
      userId: json['userId'],
      goalType: GoalType.values.firstWhere((e) => e.toString() == 'GoalType.' + json['goalType']),
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      weight: json['weight'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      //goalStatus: json['goalStatus'] != null ? GoalStatus.values.firstWhere((e) => e.toString() == 'GoalStatus.' + json['goalStatus']) : null,
      activityLevel: ActivityLevel.values.firstWhere((e) => e.toString() == 'ActivityLevel.' + json['activityLevel']),
      //createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Phương thức chuyển đổi GoalDTO thành JSON để gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'goalType': goalType.toString().split('.').last, // Chuyển enum thành string
      'targetValue': targetValue,
      'currentValue': currentValue,
      'weight': weight,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      //'goalStatus': goalStatus?.toString().split('.').last,
      'activityLevel': activityLevel.toString().split('.').last,
      //'createdAt': createdAt.toIso8601String(),
    };
  }
}
