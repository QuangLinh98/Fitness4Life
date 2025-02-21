
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/Home/data/Branch.dart';

class BranchRepository {
  final ApiGateWayService _apiGateWayService;

  BranchRepository(this._apiGateWayService);

  //Lấy danh sách trainer
  Future<List<Branch>> getAllBranchs() async {
    try {
      final response = await _apiGateWayService.getData('/dashboard/branchs');
      // print("Response status code: ${response.statusCode}");
       print("Response data: ${response.data}");

      // Chuyển đổi dữ liệu thành danh sách Trainer
      return (response.data['data'] as List)
          .map((json) => Branch.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Error fetching branchs: $e");
    }
  }
}