import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal.dart';

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
}
