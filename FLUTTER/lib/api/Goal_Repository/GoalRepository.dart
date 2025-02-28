import 'dart:convert';

import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';

class GoalRepository {
  final ApiGateWayService _apiGateWayService;

  GoalRepository(this._apiGateWayService);

  Future<List<Goal>> getAllGoals() async {
    try {
      // Gọi API để lấy dữ liệu
      final response = await _apiGateWayService.getData('/goal/all');
      print("Response data: ${response.data}");

      // Kiểm tra cấu trúc JSON trả về
      if (response.data != null && response.data is List) {
        return (response.data as List).map((item) {
          // Loại bỏ các trường không cần thiết
          final json = Map<String, dynamic>.from(item);
          json.remove('goalExtensions');
          json.remove('progresses');
          json.remove('dietPlans');

          // Parse JSON thành Goal
          return Goal.fromJson(json);
        }).toList();
      } else {
        throw Exception("Invalid data structure: Expected a List.");
      }
    } catch (e, stackTrace) {
      print("Error fetching goals: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error fetching goals: $e");
    }
  }

  //Hàm xử lý lấy Goal theo UserId
  Future<List<Goal>> getGoalByUserId (int userId) async {
    try{
      final response = await _apiGateWayService.getData('/goal/user/$userId');
      // Kiểm tra cấu trúc JSON trả về
      if (response.data != null && response.data is List) {
        return (response.data as List).map((item) {
          // Loại bỏ các trường không cần thiết
          final json = Map<String, dynamic>.from(item);
          json.remove('goalExtensions');
          json.remove('progresses');
          json.remove('dietPlans');

          // Parse JSON thành Goal
          return Goal.fromJson(json);
        }).toList();
      } else {
        throw Exception("Invalid data structure: Expected a List.");
      }
    }catch (e, stackTrace) {
      print("Error fetching goals: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error fetching goals: $e");
    }
  }

  Future<Goal> submitGoal(GoalDTO goalDTO) async {
    try {
      final response = await _apiGateWayService.postData('/goal/add',
          data: goalDTO.toJson());
      if (response.statusCode == 201) {
        print('Goal : ${response.data}');
        return Goal.fromJson(response.data['data']); // Trả về Goal với id
      } else {
        throw Exception('Failed to create goal');
      }
    } catch (e) {
      print("Error submitting goal: $e");
      rethrow;
    }
  }

  //Get Goal By Id
  Future<Goal> getGoalById(int goalId) async {
    try {
      final response = await _apiGateWayService.getData('/goal/$goalId');
      print('Goal response : ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        print("Goal response :  $data");
        return Goal.fromJson(data);
      } else {
        throw Exception("Failed to load goal");
      }
    } catch (e) {
      print("Error fetching goal from backend: $e");
      rethrow;
    }
  }

  //Get User of BMI
  Future<double> fetchBMI(double weight, int userId) async {
    try {
      final response = await _apiGateWayService.getData(
          '/goal/bmi?weight=$weight&userId=$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'];// Trả về giá trị BMI
      } else {
        throw Exception('Error calculating BMI');
      }
    } catch (e) {
      throw Exception('Error fetching BMI from backend: $e');
    }
  }

  //Delete Goal By Id
  Future<void> deleteGoalById(int goalId) async {
    try{
      final request = await _apiGateWayService.deleteData('/goal/delete/$goalId');
      if (request.statusCode == 200) {
        print("Delete goal successfully");
      } else {
        throw Exception("Failed to delete goal");
      }
    }catch (e) {
      print("Error delete goal: $e");
      rethrow;
    }
  }
}
