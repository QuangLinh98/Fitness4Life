import 'dart:io';

import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/features/user/data/models/User.dart';
import 'package:flutter/cupertino.dart';

import 'FaceValidation.dart';

class LoginService extends ChangeNotifier {
  final LoginRepository _loginRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _loggedInUser;
  double? faceDistance;
  String? _faceValidationMessage;

  LoginService(this._loginRepository);

  // Getters for UI to consume
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get loggedInUser => _loggedInUser;
  String? get faceValidationMessage => _faceValidationMessage;

  //Xử lý login
  Future<void> login(String email , String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final user = await _loginRepository.login(email, password);
      _loggedInUser = user;

      // Notify listeners after successful login
      _isLoading = false;
      notifyListeners();
    }
    catch (e) {
      // Handle error and notify UI
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  //Xử lý Logout
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      await _loginRepository.logout();

      // Xóa thông tin người dùng sau khi logout
      _loggedInUser = null;

      // Đặt lại trạng thái
      _isLoading = false;
      notifyListeners();
    }catch (e) {
      // Xử lý lỗi và thông báo tới UI
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

//xử lý loginFaceID
  Future<void> loginByFaceId(File imageFile) async {
    try {
      print("🔄 Start Face Authentication");
      _isLoading = true;
      _errorMessage = null;
      _faceValidationMessage = null;
      notifyListeners();

      // Kiểm tra file ảnh
      if (!imageFile.existsSync()) {
        throw Exception("The image file does not exist");
      }

      // Validate face
      final validationResult = await FaceValidator.validateFace(imageFile);
      if (!validationResult.isValid) {
        throw Exception(validationResult.message);
      }

      print("✅ Xác thực khuôn mặt thành công, đang tiến hành đăng nhập");
      _faceValidationMessage = "Handling login...";
      notifyListeners();

      // Gọi API đăng nhập
      final user = await _loginRepository.loginByFaceId(imageFile);
      if (user == null) {
        throw Exception("Unable to authenticate users");
      }

      _loggedInUser = user;
      _errorMessage = null;
      _faceValidationMessage = null;
      _isLoading = false;

      print("✅ Login Successfully");
      notifyListeners();

    } catch (e) {
      print("❌ Error: ${e.toString()}");
      _loggedInUser = null;
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _faceValidationMessage = null;
      _isLoading = false;
      notifyListeners();
      throw e; // Ném lỗi để UI có thể xử lý
    }
  }

}