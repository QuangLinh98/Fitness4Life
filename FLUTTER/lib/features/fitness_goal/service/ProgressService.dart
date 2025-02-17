import 'package:fitness4life/api/Goal_Repository/ProgressRepository.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/Progress.dart';
import 'package:flutter/cupertino.dart';

class ProgressService extends ChangeNotifier{
  final ProgressRepository _progressRepository;
  List<Progress> progress = [];
  bool isLoading = false;
  String errorMessage = '';

  ProgressService(this._progressRepository);

  Future<void> fetchProgressByGoalId(int goalId) async {
    isLoading = true;
    try {
      progress = await _progressRepository.getProgressByGoalId(goalId);
      errorMessage = '';
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Error fetching progress: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }
}