import 'dart:convert';

import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/Progress.dart';

class ProgressRepository {
  final ApiGateWayService _apiGateWayService;

  ProgressRepository(this._apiGateWayService);

  Future<List<Progress>> getProgressByGoalId(int goalId) async {
    try {
      final response = await _apiGateWayService.getData('/goal/progress/$goalId');
      print("API Response: ${response.data}");  // ✅ Kiểm tra phản hồi từ API

      if (response.data != null && response.data is List) {
        return (response.data as List).map((json) {
          return Progress.fromJson(json);
        }).toList();
      } else {
        throw Exception("Invalid data structure: Expected a List.");
      }
    } catch (e, stackTrace) {
      print("Error fetching progress: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error fetching progress: $e");
    }
  }

}