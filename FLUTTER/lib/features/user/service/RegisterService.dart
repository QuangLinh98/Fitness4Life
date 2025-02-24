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

  //Xử lý verify account
 Future<void> verifyAccount(String code) async {
   _isLoading = true;
   _errorMessage = null;
   notifyListeners(); // Thông báo UI
    try{
      await _registerRepository.verifyAccount(code);
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

}