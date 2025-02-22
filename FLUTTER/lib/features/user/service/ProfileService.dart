import 'package:fitness4life/api/User_Repository/ProfileRepository.dart';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileService(this._profileRepository);

  Future<bool> updateUserProfile({
    required int userId,
    required String fullName,
    required String phone,
    required String gender,
    required String maritalStatus,
    required String hobbies,
    required String address,
    required int age,
    required int heightValue,
    required String description,
  }) async {
    try {
      final bool isSuccess = await _profileRepository.updateProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        gender: gender,
        maritalStatus: maritalStatus,
        hobbies: hobbies,
        address: address,
        age: age,
        heightValue: heightValue,
        description: description,
      );

      if (isSuccess) {
        notifyListeners(); // Thông báo cập nhật UI nếu cần
      }
      return isSuccess;
    } catch (e) {
      print("Error updating profile in service: \$e");
      return false;
    }
  }
}
