import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class GoalService extends ChangeNotifier {
    final GoalRepository _goalRepository;
    List<Goal> goals = [];
    int? goalId;
    bool isLoading = false;
    String errorMessage = '';

    GoalService(this._goalRepository);

    //Get All Data
     Future<void> fetchGoals() async {
       isLoading = true;
       notifyListeners();
       try{
         goals = await _goalRepository.getAllGoals();
       }
       catch(e) {
         print("Error fetching goal: $e");
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
      notifyListeners();

      try {
        // Gọi API để gửi GoalDTO xuống backend và nhận phản hồi
        final goalData = await _goalRepository.submitGoal(goalDTO);

        // Lưu goalId vào GoalSetupState (hoặc bất kỳ state nào bạn đang sử dụng)
        goalState.setGoalId(goalData.id!); // Lưu id trả về từ backend

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
      return await _goalRepository.fetchBMI(weight, userId);
    }

}