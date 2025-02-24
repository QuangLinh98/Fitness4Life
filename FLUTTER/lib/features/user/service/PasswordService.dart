import 'package:fitness4life/api/User_Repository/PasswordRepository.dart';
import 'package:flutter/cupertino.dart';

class PasswordService extends ChangeNotifier {
  final PasswordRepository _passwordRepository;

  PasswordService(this._passwordRepository);

  bool _isLoading = false;
  String? _errorMessage;

  // Getters cho UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> changePassword(String oldPass , String newPass , String confirmPass) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();   // Cập nhật UI
    try{
        await _passwordRepository.changedPassword(oldPass, newPass, confirmPass);

        // Thành công, cập nhật trạng thái
        _isLoading = false;
        notifyListeners();
    }
    catch (e) {
      // Xử lý lỗi và thông báo tới UI
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  //Xử lý send Otp
  Future<void> sendOtpPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();   // Cập nhật UI
    try{
       await _passwordRepository.sendOtpPassword(email);
       // Thành công, cập nhật trạng thái
       _isLoading = false;
       notifyListeners();
    }
    catch (e) {
      // Xử lý lỗi và thông báo tới UI
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  //Xử lý reset password
  Future<void> resetPassword(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try{
      await _passwordRepository.resetPassword(otp);
      print("OTP being sent: $otp");

      // Thành công, cập nhật trạng thái
      _isLoading = false;
      notifyListeners();
    }
    catch(e){
      // Xử lý lỗi và thông báo tới UI
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}