import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';
import 'package:http_parser/http_parser.dart';

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

  ///Xác thực tài faceId
  Future<Map<String, dynamic>> verifyAccount2(String code) async {
    try {
      final response =
      await _apiGateWayService.getData('/users/verify-account2/$code');
      if (response.statusCode == 200) {
        print("Verification successful: ${response.data}");
        // Kiểm tra cấu trúc response
        if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data']; // Trả về phần 'data' từ ApiResponse
        }
        return response
            .data; // Hoặc trả về toàn bộ dữ liệu nếu không có cấu trúc 'data'
      } else {
        throw Exception("Verification failed: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Error during verify account: $e");
    }
  }

  Future<dynamic> registerFace(File faceImage, int userId, String token) async {
    try {
      // Lấy tên file
      String fileName = faceImage.path.split('/').last;

      // Xác định MIME type chính xác dựa vào extension
      String mimeType = fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')
          ? 'image/jpeg'
          : (fileName.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg');

      // Tạo form data để gửi ảnh
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          faceImage.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        "min_face_size": 20,
      });

      // Gửi ảnh lên server với token xác thực
      final response = await _apiGateWayService.postDataWithFormData(
        '/face-auth/register/$userId',
        formData: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Không cần set Content-Type ở đây vì Dio sẽ tự xử lý với FormData
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Đăng ký khuôn mặt thành công: ${response.data}");
        return response.data;
      } else {
        throw Exception(
            "Đăng ký khuôn mặt thất bại: ${response.statusCode} - ${response.data['message']}");
      }
    } catch (e) {
      // Xử lý chi tiết các ngoại lệ
      if (e.toString().contains("face is already registered")) {
        throw Exception("This face has already been registered to another account. Multiple registrations are not possible.");
      }
      throw Exception("Error while registering face: $e");
    }
  }
}