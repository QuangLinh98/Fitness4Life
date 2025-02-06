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
        int? id = payload['id'] is int ? payload['id'] : int.tryParse(payload['id'].toString()); // Trích xuất ID

        print('Full Name: $fullname');
        print('Role: $role');
        print('ID: $id');
        // Lưu token vào Secure Storage
        await TokenManager.saveTokens(accessToken, refreshToken);

        //===== phần thêm=====
        // ✅ Lưu email vào SharedPreferences
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('user_email', email);

        // Gọi getUserByEmail để lấy thông tin user
        // final userInfo = await getUserByEmail(email);

        // ✅ Lưu thông tin user vào SharedPreferences
        // await prefs.setInt('user_id', userInfo.id ?? 0);
        // await prefs.setString('user_fullname', userInfo.fullname ?? "Guest");
        //
        // print("✅ Thông tin người dùng: ID=${userInfo.id}, Name=${userInfo.fullname}");
        //====================

        // Tạo đối tượng User từ dữ liệu giải mã
        final user = User(
          id: id ?? 0,
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
  
  // Future<GetUser> getUserByEmail(String email) async {
  //   try {
  //     final response = await _apiGateWayService.getData("/users/manager/userByEmail/$email");
  //
  //     if (response.statusCode == 200) {
  //       return GetUser.fromJson(response.data);
  //     } else {
  //       throw Exception("Failed to fetch user data. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Error fetching user data: $e");
  //   }
  // }

  //Xử lý Logout
  Future<void> logout() async {
    try{
      final response = await _apiGateWayService.postData("/users/logout");
      if(response.statusCode == 200) {
        //Xóa token khởi Secure Store
        await TokenManager.clearTokens();

        //===== phần thêm=====
        // ✅ Xóa email & thông tin user khỏi SharedPreferences
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.remove('user_email');
        // await prefs.remove('user_id');
        // await prefs.remove('user_fullname');
        // print("🚫 Đã xóa thông tin người dùng khỏi SharedPreferences");
        //====================

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