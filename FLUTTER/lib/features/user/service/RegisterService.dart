import 'dart:io';

import 'package:fitness4life/api/User_Repository/RegisterRepository.dart';
import 'package:fitness4life/features/user/data/models/CreateUserDTO.dart';
import 'package:flutter/material.dart';

class RegisterService extends ChangeNotifier {
  final RegisterRepository _registerRepository;

  RegisterService(this._registerRepository);

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> registerAccount(
       String fullName,
       String email,
       String password,
       String confirmPassword,
       String gender,
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo UI
    try{
      await _registerRepository.registerAccount(fullName, email, password, confirmPassword, gender,);
      _isLoading = false;
      notifyListeners();
    }
    catch(e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners(); // Thông báo UI lỗi
      rethrow;
    }
  }
//verify account
  Future<Map<String, dynamic>> verifyAccount(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo UI
    try {
      final response = await _registerRepository.verifyAccount(code);
      _isLoading = false;
      notifyListeners();
      return response; // Trả về dữ liệu từ API bao gồm userId
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners(); // Thông báo UI lỗi
      rethrow;
    }
  }

// Phương thức đăng ký khuôn mặt
  Future<dynamic> registerFace(File faceImage, int userId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo UI đang loading

    try {
      // Gọi API đăng ký khuôn mặt từ repository
      String fileName = faceImage.path.split('/').last;
      print("File path: ${faceImage.path}");
      print("File name: $fileName");
      print("File size: ${await faceImage.length()} bytes");
      print("File exists: ${await faceImage.exists()}");
      final response = await _registerRepository.registerFace(faceImage, userId, token);
      _isLoading = false;
      notifyListeners(); // Thông báo UI thành công
      return response; // Trả về dữ liệu từ API
    } catch (e) {
      _isLoading = false;
      // Xử lý thông báo lỗi chi tiết hơn
      _errorMessage = e is Exception ? e.toString() : "Lỗi không xác định khi đăng ký khuôn mặt";
      notifyListeners(); // Thông báo UI lỗi
      rethrow; // Ném lại lỗi để xử lý ở UI nếu cần
    }
  }
}