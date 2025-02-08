import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/user/data/models/User.dart';
import 'package:fitness4life/token/token_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        print("Response data: ${response.data}");

        // Lấy access_token và refresh_token từ phản hồi
        String accessToken = response.data['access_token'];
        String refreshToken = response.data['refresh_token'];


        // Giải mã token để lấy thông tin người dùng
        Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
        String? fullname = payload['fullName']; // Trích xuất trường fullName
        String? role = payload['role']; // Trích xuất role
        int? id = payload['id'];

        if (id == null) {
          throw Exception("User ID is null in the token payload.");
        }

        // Lưu token vào Secure Storage
        await TokenManager.saveTokens(accessToken, refreshToken);

        //  Lưu userId vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', id);
        print("✅ Saved userId to SharedPreferences: $id");

        // Tạo đối tượng User từ dữ liệu giải mã
        final user = User(
          fullname: fullname ?? "Guest",
          role: role ,
          id:id,
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

        // 🛑 Xóa userId khỏi SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');
        print("✅ Removed userId from SharedPreferences");

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