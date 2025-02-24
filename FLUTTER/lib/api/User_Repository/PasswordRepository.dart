import 'package:fitness4life/api/api_gateway.dart';

class PasswordRepository {
  final ApiGateWayService _apiGateWayService;

  PasswordRepository(this._apiGateWayService);

  Future<void> changedPassword(
      String oldPass , String newPass , String confirmPass) async {
    try{
        final response = await _apiGateWayService.postData(
            '/users/change-pass',
            data: {
              'oldPassword': oldPass,
              'newPassword': newPass,
              'confirmPassword': confirmPass,
            },
        );
        print("Response : ${response.data}");
        if(response.statusCode == 200) {
          //thành công
          print("Password changed successfully: ${response.data}");
        } if (response.statusCode != 200) {
          throw Exception(response.data['message'] ?? "Failed to change password"); // Ném ngoại lệ với thông báo lỗi từ backend
        }
    }
    catch (e) {
      throw Exception("Error during password change: $e");
    }
  }

  //Xử lý send Otp cho chức năng forgot password
  Future<void> sendOtpPassword(String email) async {
    try{
      final response = await _apiGateWayService.postData(
          '/users/send-otp',
          data: {
            'email': email
          }
      );
      print("Response : ${response.data}");
      if(response.statusCode == 200) {
        //thành công
        print("Send email successfully : ${response.data}");
      }
    }
    catch (e) {
      throw Exception("Error during send otp : $e");
    }
  }

  //Xử lý reset password
  Future<void> resetPassword(String otp) async {
    try{
      final response = await _apiGateWayService.postData(
          '/users/reset-password',
        data:{
            'otpCode': otp
        }
      );
      if(response.statusCode == 200) {
        //thành công
        print("Send email successfully : ${response.data}");
      }
    }
    catch (e) {
      throw Exception("Error during reset password : $e");
    }
  }
}