import '../Progress/Progress.dart';

class Goal {
  int? id;
  int? userId;
  String? fullName;
  String? goalType;
  double? targetValue;
  double? currentValue;
  double? weight;
  DateTime? startDate;
  DateTime? endDate;
  String? goalStatus;
  String? activityLevel;
  double? targetCalories;
  List<ExerciseDietSuggestions> dietPlans;
  DateTime? createdAt;
  List<Progress> progress;

  Goal({
    this.id,
    this.userId,
    this.fullName,
    this.goalType,
    this.targetValue,
    this.currentValue,
    this.weight,
    this.startDate,
    this.endDate,
    this.goalStatus,
    this.activityLevel,
    this.targetCalories,
    required this.dietPlans,
    this.createdAt,
    required this.progress,
  });

  // Factory để parse từ JSON
  factory Goal.fromJson(Map<String, dynamic> json) {
    var dietPlansJson = json['dietPlans'] as List?;  // Kiểm tra dietPlans có phải là null không

    List<ExerciseDietSuggestions> dietPlans = dietPlansJson == null
        ? []  // Nếu dietPlans là null, gán danh sách rỗng
        : dietPlansJson.map((i) => ExerciseDietSuggestions.fromJson(i)).toList();

    var progressJson = json.containsKey('progresses') ? json['progresses'] as List? ?? [] : [];
    if (progressJson.isEmpty) {
      print("⚠️ Warning: API trả về progresses nhưng rỗng!");
    }

    List<Progress> progressList =
    progressJson.map((i) => Progress.fromJson(i)).toList();

    return Goal(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      goalType: json['goalType'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      weight: json['weight'],
      startDate: _parseLocalDate(json['startDate']),
      endDate: _parseLocalDate(json['endDate']),
      goalStatus: json['goalStatus'],
      activityLevel: json['activityLevel'],
      targetCalories: json['targetCalories'],
      dietPlans: dietPlans,
      createdAt: _parseLocalDateTime(json['createdAt']),
      progress: progressList,
    );
  }

  // Chuyển từ DTO sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'goalType': goalType,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'weight': weight,
      'startDate': startDate != null
          ? [startDate!.year, startDate!.month, startDate!.day]
          : null,
      'endDate': endDate != null
          ? [endDate!.year, endDate!.month, endDate!.day]
          : null,
      'goalStatus': goalStatus,
      'activityLevel': activityLevel,
      'targetCalories': targetCalories,
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
      'progressHistory': progress.map((p) => p.toJson()).toList(),
    };
  }

  // Hàm parse LocalDate từ JSON (dạng List<int>)
  static DateTime? _parseLocalDate(dynamic localDate) {
    if (localDate == null || !(localDate is List) || localDate.length < 3) {
      return null;
    }
    return DateTime(localDate[0], localDate[1], localDate[2]);
  }

  // Hàm parse LocalDateTime từ JSON (dạng List<int>)
  static DateTime? _parseLocalDateTime(dynamic localDateTime) {
    if (localDateTime == null || !(localDateTime is List) || localDateTime.length < 6) {
      return null;
    }
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
}

class ExerciseDietSuggestions {
  final String dietPlan;
  final String workoutPlan;

  ExerciseDietSuggestions({required this.dietPlan, required this.workoutPlan});

  factory ExerciseDietSuggestions.fromJson(Map<String, dynamic> json) {
    return ExerciseDietSuggestions(
      dietPlan: json['dietPlan'],
      workoutPlan: json['workoutPlan'],
    );
  }
}
