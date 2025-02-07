import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/user/data/models/User.dart';
import 'package:fitness4life/token/token_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/user/data/models/GetUser.dart';

class LoginRepository {
  final ApiGateWayService _apiGateWayService;

  LoginRepository(this._apiGateWayService);

  //Xử lý Login
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiGateWayService.postData(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        print("Response data user: ${response.data}");

        // Lấy access_token và refresh_token từ phản hồi
        String accessToken = response.data['access_token'];
        String refreshToken = response.data['refresh_token'];


        // Giải mã token để lấy thông tin người dùng
        Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
        // print("Decoded JWT Payload: $payload");

        String? fullname = payload['fullName']; // Trích xuất trường fullName
        String? role = payload['role']; // Trích xuất role
        int? userId = payload['userId'];
        // Lưu token vào Secure Storage
        await TokenManager.saveTokens(accessToken, refreshToken);

        // ✅ Lưu data vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setInt('user_id', userId!);
        await prefs.setString('user_fullname', fullname!);

        // 🛠 Log dữ liệu đã lưu
        // print("✅ Dữ liệu SharedPreferences sau khi đăng nhập:");
        // print("📌 Email: ${prefs.getString('user_email')}");
        // print("📌 User ID: ${prefs.getInt('user_id')}");
        // print("📌 Full Name: ${prefs.getString('user_fullname')}");

        // Tạo đối tượng User từ dữ liệu giải mã
        final user = User(
          fullname: fullname ?? "Guest",
          role: role ,
          tokensList: [
            Tokens(value: accessToken, type: "access_token"),
            Tokens(value: response.data['refresh_token'], type: "refresh_token"),
          ],
        );

        return user;
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception("Invalid email or password.");
      } else if (response.statusCode == 403) {
        // Forbidden
        throw Exception("Access denied.");
      } else {
        // Other errors
        throw Exception("Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during login: $e");
    }
  }

  //Xử lý Logout
  Future<void> logout() async {
    try{
      final response = await _apiGateWayService.postData("/users/logout");
      if(response.statusCode == 200) {
        //Xóa token khởi Secure Store
        await TokenManager.clearTokens();

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_email');
        await prefs.remove('user_id');
        await prefs.remove('user_fullname');

        // 🛠 Log dữ liệu sau khi xóa
        // print("🚫 Đã xóa thông tin người dùng khỏi SharedPreferences.");
        // print("📌 Email: ${prefs.getString('user_email')}");
        // print("📌 User ID: ${prefs.getInt('user_id')}");
        // print("📌 Full Name: ${prefs.getString('user_fullname')}");

        print("User successfully logged out");
      }else {
        // Xử lý các mã lỗi khác
        throw Exception("Failed to logout. Status code: ${response.statusCode}");
      }
    }
    catch(e) {
      throw Exception("Error during login: $e");
    }
  }


}