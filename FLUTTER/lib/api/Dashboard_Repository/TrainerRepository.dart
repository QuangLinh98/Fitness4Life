
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/Home/data/Trainer.dart';

class TrainerRepository {
  final ApiGateWayService _apiGateWayService;

  TrainerRepository(this._apiGateWayService);

  //Lấy danh sách trainer
  Future<List<Trainer>> getAllTrainers() async {
    try {
      final response = await _apiGateWayService.getData('/dashboard/trainers');
      // print("Response status code: ${response.statusCode}");
      // print("Response data: ${response.data}");

      // Chuyển đổi dữ liệu thành danh sách Trainer
      return (response.data['data'] as List)
          .map((json) => Trainer.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching trainers: $e");
      throw Exception("Error fetching trainers: $e");
    }
  }
}