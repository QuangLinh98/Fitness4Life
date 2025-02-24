import 'package:fitness4life/api/Goal_Repository/ProgressRepository.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/Progress.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/ProgressDTO.dart';
import 'package:flutter/cupertino.dart';

class ProgressService extends ChangeNotifier{
  final ProgressRepository _progressRepository;
  List<Progress> progress = [];
  bool isLoading = false;
  String errorMessage = '';

  ProgressService(this._progressRepository);

  Future<void> fetchProgressByGoalId(int goalId) async {
    isLoading = true;
    notifyListeners();
    try {
      List<Progress> newProgress = await _progressRepository.getProgressByGoalId(goalId);
      progress.clear(); // ✅ Xóa danh sách cũ trước khi cập nhật
      errorMessage = '';
      progress.addAll(newProgress); // ✅ Thêm dữ liệu mới
      errorMessage = '';
    } catch (e) {
      print("Error fetching progress: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProgress(ProgressDTO progress) async {
    isLoading = true;
    errorMessage = ''; // Reset error message trước khi gọi API
    notifyListeners();

    try {
      ProgressDTO newProgress = await _progressRepository.createProgress(progress);
      print("Progress created successfully: ${newProgress.toJson()}");

      // ✅ Gọi lại fetchProgressByGoalId để cập nhật danh sách ngay sau khi tạo
      await fetchProgressByGoalId(progress.goal!);
    } catch (e) {
      errorMessage = "Failed to create progress: $e"; // Cập nhật lỗi để UI có thể hiển thị
      print("Error create progress: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}