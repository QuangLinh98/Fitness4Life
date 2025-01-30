import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/booking/data/WorkoutPackage.dart';

class WorkoutPackageRepository {
  final ApiGateWayService _apiGateWayService;
  WorkoutPackageRepository(this._apiGateWayService);

  Future<List<WorkoutPackage>> fetchWorkoutPackages() async {
    try {
      final response = await _apiGateWayService.getData('/booking/packages');

      // 🔥 Log phản hồi để kiểm tra
      print("Package response : ${response.data}");

      // Kiểm tra nếu response.data là null hoặc không chứa key "data"
      if (response.data == null || response.data['data'] == null) {
        throw Exception("API response is null or does not contain 'data'");
      }

      // ✅ Trực tiếp sử dụng danh sách thay vì decode lại
      final List<dynamic> data = response.data['data'];

      // Chuyển đổi danh sách thành danh sách đối tượng WorkoutPackage
      return data.map((json) => WorkoutPackage.fromJson(json)).toList();
    } catch (e, stacktrace) {
      print("❌ Error fetching Workout Package: $e");
      print("🔍 StackTrace: $stacktrace");
      throw Exception("Error fetching Workout Package: $e");
    }
  }}