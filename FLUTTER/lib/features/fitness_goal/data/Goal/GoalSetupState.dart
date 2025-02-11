import 'package:flutter/material.dart';

class GoalSetupState with ChangeNotifier {
  String? goalType;
  double? weight;
  double? currentValue;
  double? targetValue;
  String? startDate;
  String? endDate;
  String activityLevel = "SEDENTARY"; // Giá trị mặc định
  bool isKgSelected = true;

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

  void setUnit(bool isKg) {
    isKgSelected = isKg;
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
