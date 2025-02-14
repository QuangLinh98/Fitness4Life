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

  Future<void> submitGoal(GoalDTO goalDTO) async {
    try{
      if(goalDTO.userId == null) {
        throw Exception("userId is required to submit goal");
      }
      print("Data being sent to backend: ${goalDTO.toJson()}");

      final request = await _apiGateWayService.postData(
          '/goal/add',
          data: goalDTO.toJson()
      );

      print('Send request to backend : ${request.data}');
      if (request.statusCode == 201) {
        // Xử lý thành công, trả về thông báo hoặc dữ liệu
        print("Goal created successfully");
      } else {
        // Xử lý lỗi nếu cần thiết
        print("Error creating goal: ${request.statusCode}");
        throw Exception("Failed to create goal: ${request.statusCode}");
      }
    }catch (e, stackTrace) {
      print("Error submitting goal: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error submitting goal: $e");
    }
  }
}
