import 'package:fitness4life/api/api_gateway.dart';

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
        if (response.statusCode == 201) {
          print("Registration successful: ${response.data}");
        } else {
          throw Exception("Registration failed: ${response.data['message']}");
        }
    }
    catch (e) {
      throw Exception("Error during registration: $e");
    }
  }

  //Xử lý verify account
  Future<void> verifyAccount(String code) async {
    try{
       final response = await _apiGateWayService.getData('/users/verify-account/$code');
       if (response.statusCode == 200) {
         print("Registration successful: ${response.data}");
       } else {
         throw Exception("Registration failed: ${response.data['message']}");
       }
    }
    catch (e) {
      throw Exception("Error during verify account: $e");
    }
  }
}