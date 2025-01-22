import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/user/data/models/CreateUserDTO.dart';

class RegisterRepository {
  final ApiGateWayService _apiGateWayService;

  RegisterRepository(this._apiGateWayService);

  Future<void> registerAccount(
       String fullName,
       String email,
       String password,
       String confirmPassword,
       String gender,
      ) async {
    try{
      print("Co lot vao khong ");
        final response = await _apiGateWayService.postData(
          '/users/register',
          data: {
            'fullName': fullName,
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword,
            'gender': gender,
          },
        );
      print("Co lot vao duoi  ");
        if (response.statusCode == 200) {
          print("Registration successful: ${response.data}");
        } else {
          throw Exception("Registration failed: ${response.data['message']}");
        }
    }
    catch (e) {
      throw Exception("Error during registration: $e");
    }
  }
}