import 'package:flutter/material.dart';

class GoalSetupState with ChangeNotifier {
  String? goalType;
  double? targetValue;
  double? currentValue;
  double? weight;
  String? startDate;
  String? endDate;
  String activityLevel = "SEDENTARY"; // Giá trị mặc định

  void setGoalType(String type) {
    goalType = type;
    notifyListeners();
  }

  void setTargetValue(double value) {
    targetValue = value;
    notifyListeners();
  }

  void setCurrentValue(double value) {
    currentValue = value;
    notifyListeners();
  }

  void setWeight(double value) {
    weight = value;
    notifyListeners();
  }

  void setActivityLevel(String level) {
    activityLevel = level;
    notifyListeners();
  }

  void setStartDate(String date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(String date) {
    endDate = date;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      "goalType": goalType,
      "targetValue": targetValue,
      "currentValue": currentValue,
      "weight": weight,
      "startDate": startDate,
      "endDate": endDate,
      "activityLevel": activityLevel
    };
  }
}
