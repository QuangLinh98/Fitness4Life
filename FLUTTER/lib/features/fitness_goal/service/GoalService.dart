import 'package:fitness4life/api/Goal_Repository/GoalRepository.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:flutter/cupertino.dart';

class GoalService extends ChangeNotifier {
    final GoalRepository _goalRepository;
    List<Goal> goals = [];
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
     Future<void> submitGoal(GoalDTO goalDTO) async {
       isLoading = true;
       notifyListeners();
       try {
         // Call the repository to submit goal
         await _goalRepository.submitGoal(goalDTO);
       } catch (e) {
         print("Error submitting goal: $e");
         errorMessage = "Error submitting goal. Please try again later."; // Thêm thông báo lỗi
       } finally {
         isLoading = false;
         notifyListeners();
       }
     }

}