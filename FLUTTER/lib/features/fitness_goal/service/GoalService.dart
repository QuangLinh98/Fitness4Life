import 'dart:convert';

import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalService extends ChangeNotifier {
    final GoalRepository _goalRepository;
    List<Goal> goals = [];
    int? goalId;
    bool isLoading = false;
    String errorMessage = '';

    GoalService(this._goalRepository);

    // Lưu danh sách Goals vào SharedPreferences
    Future<void> saveGoalsToSharedPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      // Chuyển List<Goal> thành List<String> của chuỗi JSON
      List<String> goalJsonList = goals.map((goal) => jsonEncode(goal.toJson())).toList();
      await prefs.setStringList('goals', goalJsonList);
      print("Goals saved to SharedPreferences");
    }

    // Lấy danh sách Goals từ SharedPreferences
    Future<void> loadGoalsFromSharedPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      List<String>? goalJsonList = prefs.getStringList('goals');
      if (goalJsonList != null) {
        goals = goalJsonList.map((goalJson) => Goal.fromJson(jsonDecode(goalJson))).toList();
        notifyListeners();
      }
    }

    //Get All Data
     Future<void> fetchGoals() async {
       isLoading = true;
       notifyListeners();
       try{
         goals = await _goalRepository.getAllGoals();
         // Sau khi lấy dữ liệu, lưu vào SharedPreferences
         //saveGoalsToSharedPreferences();
       }
       catch(e) {
         print("Error fetching goal: $e");
       }
       finally {
         isLoading = false;
         notifyListeners();
       }
     }

    //Get Goal By UserId
    Future<void> fetchGoalsByUserId(int userId) async {
      isLoading = true;
      notifyListeners();
      try{
        goals = await _goalRepository.getGoalByUserId(userId);
        // Sau khi lấy dữ liệu, lưu vào SharedPreferences
        //saveGoalsToSharedPreferences();
      }
      catch(e) {
        print("Error fetching goal by userId: $e");
      }
      finally {
        isLoading = false;
        notifyListeners();
      }
    }

     //Create Goal
    Future<void> submitGoal(BuildContext context, GoalDTO goalDTO) async {
      final goalState = Provider.of<GoalSetupState>(context, listen: false); // Lấy goalState từ Provider
      isLoading = true;
      try {
        // Gọi API để gửi GoalDTO xuống backend và nhận phản hồi
        final goalData = await _goalRepository.submitGoal(goalDTO);

        // Lưu goalId vào GoalSetupState (hoặc bất kỳ state nào bạn đang sử dụng)
        goalState.setGoalId(goalData.id!); // Lưu id trả về từ backend
        notifyListeners();
        print("Goal created successfully with ID: ${goalData.id}");

        // Tiến hành các bước tiếp theo (chuyển màn hình, v.v.)
      } catch (e) {
        print("Error submitting goal: $e");
        errorMessage = "Error submitting goal. Please try again later."; // Thêm thông báo lỗi
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

    Future<Goal> getGoalById(int goalId) async {
      if (goalId != null) {
        isLoading = true;
        notifyListeners();
        try {
          final goalData = await _goalRepository.getGoalById(goalId);
          return goalData; // Trả về goal từ backend
        } catch (e) {
          errorMessage = "Error fetching goal: $e";
          print("Error fetching goal: $e");
          rethrow;
        } finally {
          isLoading = false;
          notifyListeners();
        }
      }
      throw Exception("GoalId is null");
    }

    Future<double> getBMI(double weight, int userId) async {
      isLoading = true;
      notifyListeners();
      return await _goalRepository.fetchBMI(weight, userId);
    }

    Future<void> deleteGoalById(int goalId) async {
      isLoading = true;

      try{
         await _goalRepository.deleteGoalById(goalId);

         // Xóa mục tiêu khỏi danh sách goals
         goals.removeWhere((goal) => goal.id == goalId);

         notifyListeners();
      }catch (e) {
        errorMessage = "Error delete goal: $e";
        print("Error delete goal: $e");
        rethrow;
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

}