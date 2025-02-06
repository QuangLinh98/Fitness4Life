import 'package:fitness4life/api/User_Repository/LoginRepository.dart';
import 'package:fitness4life/features/user/data/models/User.dart';
import 'package:flutter/cupertino.dart';

class LoginService extends ChangeNotifier {
  final LoginRepository _loginRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _loggedInUser;

  LoginService(this._loginRepository);

  // Getters for UI to consume
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get loggedInUser => _loggedInUser;

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

}