import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/user/data/models/User.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/token/token_manager.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

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
        String? fullname = payload['fullName']; // Trích xuất fullName
        String? role = payload['role']; // Trích xuất role
        int? id = payload['id'];

        if (id == null) {
          throw Exception("User ID is null in the token payload.");
        }

        // Lưu token vào Secure Storage
        await TokenManager.saveTokens(accessToken, refreshToken);

        // ✅ Lấy instance của UserInfoProvider và lưu dữ liệu
        final userInfoProvider = Provider.of<UserInfoProvider>(navigatorKey.currentContext!, listen: false);
        userInfoProvider.setUserInfo(fullname ?? "Guest", id);

        print("✅ Saved user info to UserInfoProvider: id=$id, fullname=$fullname");

        // Tạo đối tượng User từ dữ liệu giải mã
        final user = User(
          fullname: fullname ?? "Guest",
          role: role,
          id: id,
          tokensList: [
            Tokens(value: accessToken, type: "access_token"),
            Tokens(value: response.data['refresh_token'], type: "refresh_token"),
          ],
        );

        return user;
      } else if (response.statusCode == 401) {
        throw Exception("Invalid email or password.");
      } else if (response.statusCode == 403) {
        throw Exception("Access denied.");
      } else {
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

        // 🛑 Xóa thông tin người dùng trong UserInfoProvider
        final userInfoProvider = Provider.of<UserInfoProvider>(navigatorKey.currentContext!, listen: false);
        userInfoProvider.logout(); // Xóa userName và userId khỏi UserInfoProvider


        // 🛑 Xóa userId khỏi SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_id');
        print("✅ Removed userId from SharedPreferences");

        // Kiểm tra lại thông tin trong UserInfoProvider
        print("UserInfoProvider after logout:");
        print("User ID: ${userInfoProvider.userId}");
        print("User Name: ${userInfoProvider.userName}");

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

  //xử lý faceID
  Future<User> loginByFaceId(File imageFile) async {
    try {
      // Validate image file
      if (!imageFile.existsSync()) {
        throw Exception("Invalid image file. Please try again.");
      }
      // Create form data for image upload
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'face_image.jpg',
            contentType: MediaType('image', 'jpeg') // Specify content type
        ),
      });

      // Make API request
      final response = await _apiGateWayService.postDataWithFormData(
        '/face-auth/login',
        formData: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          validateStatus: (status) => status! < 500, // Allow handling of 4xx errors
        ),
      );

      // Handle response based on status code
      if (response.statusCode == 200) {
        // Success case - process tokens and user data
        final String accessToken = response.data['access_token'];
        final String refreshToken = response.data['refresh_token'];

        // Decode JWT token
        final Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
        final String? fullname = payload['fullName'];
        final String? role = payload['role'];
        final int? id = payload['id'];
        print("🔑 Tokens received:");
        print("Access Token: ${accessToken.substring(0, 20)}... (truncated)");
        print("Refresh Token: ${refreshToken.substring(0, 20)}... (truncated)");
        if (id == null) {
          throw Exception("Authentication failed: Invalid user data");
        }

        // Save tokens
        await TokenManager.saveTokens(accessToken, refreshToken);

        // Update user info provider
        final userInfoProvider = Provider.of<UserInfoProvider>(
            navigatorKey.currentContext!,
            listen: false
        );
        userInfoProvider.setUserInfo(fullname ?? "Guest", id);

        // Return user object
        return User(
          fullname: fullname ?? "Guest",
          role: role,
          id: id,
          tokensList: [
            Tokens(value: accessToken, type: "access_token"),
            Tokens(value: refreshToken, type: "refresh_token"),
          ],
        );
      } else {
        // Handle specific error cases matching backend
        switch (response.statusCode) {
          case 400:
            if (response.data['detail']?.contains('No face detected')) {
              throw Exception("No face detected. Please ensure your face is clearly visible.");
            } else if (response.data['detail']?.contains('Multiple faces detected')) {
              throw Exception("Multiple faces detected. Please ensure only your face is in the image.");
            } else if (response.data['detail']?.contains('Invalid image format')) {
              throw Exception("Invalid image format. Please use a JPEG or PNG image.");
            }
            throw Exception(response.data['detail'] ?? "Face authentication failed");

          case 401:
            throw Exception("Face not recognized. Please try again or use password login.");

          case 403:
            throw Exception("Access denied. Please verify your account first.");

          default:
            throw Exception("Authentication failed. Please try again later.");
        }
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout) {
        throw Exception("Connection timeout. Please check your internet connection.");
      }

      if (dioError.response?.data != null) {
        throw Exception(dioError.response?.data['detail'] ?? "Face authentication failed");
      }

      throw Exception("Network error. Please check your connection and try again.");
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception:", ""));
    }
  }
}