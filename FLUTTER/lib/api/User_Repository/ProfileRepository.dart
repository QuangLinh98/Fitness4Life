import 'package:fitness4life/api/api_gateway.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final ApiGateWayService _apiGateWayService;

  ProfileRepository(this._apiGateWayService);

  Future<bool> updateProfile({
    required int userId,
    required String fullName,
    required String phone,
    required String gender,
    required String maritalStatus,
    required String hobbies,
    required String address,
    required int age,
    required int heightValue,
    required String description,
  }) async {
    try {
      final data = FormData.fromMap({
        'fullName': fullName,
        'phone': phone,
        'gender': gender,
        'maritalStatus': maritalStatus,
        'hobbies': hobbies,
        'address': address,
        'age': age.toString(),
        'heightValue': heightValue.toString(),
        'description': description,
      });

      final response = await _apiGateWayService.putFormData(
        '/users/update/$userId',
        formData: data,
      );

      if (response != null && response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update profile: ${response?.data}");
        return false;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

}
