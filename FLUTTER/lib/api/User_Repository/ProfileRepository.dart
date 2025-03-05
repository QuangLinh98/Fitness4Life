import 'package:fitness4life/api/api_gateway.dart';
import 'package:dio/dio.dart';
import 'package:fitness4life/features/user/data/models/UserResponseDTO.dart';

class ProfileRepository {
  final ApiGateWayService _apiGateWayService;

  ProfileRepository(this._apiGateWayService);

  //Phương thức update profile
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

  //Phương thức hiển thị profile by userId
  Future<UserResponseDTO?> getUserById(int userId) async {
    try {
      final response = await _apiGateWayService.getData('/users/manager/users/profile/$userId');
      print('get user info : ${response.data}');
      if (response != null && response.statusCode == 200) {
        return UserResponseDTO.fromJson(response.data);
      } else {
        print("Failed to fetch user profile: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

}
