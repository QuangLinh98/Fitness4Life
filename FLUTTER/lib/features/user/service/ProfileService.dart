import 'dart:async';

import 'package:fitness4life/api/User_Repository/ProfileRepository.dart';
import 'package:flutter/material.dart';

import '../../../config/PollingService.dart';
import '../data/models/UserResponseDTO.dart';

class ProfileService extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  UserResponseDTO? _userProfile;
  late PollingService _pollingService; // Thêm PollingService

  ProfileService(this._profileRepository){
    _pollingService = PollingService(fetchFunction: () async {
      if (_userProfile?.id != null) {
        await getUserById(_userProfile!.id);
      }
    });
    _pollingService.startPolling(); //  Khởi động polling
  }

  UserResponseDTO? get userProfile => _userProfile;

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
        await getUserById(userId);
      }
      return isSuccess;
    } catch (e) {
      print("Error updating profile in service: \$e");
      return false;
    }
  }

  Future<UserResponseDTO?> getUserById(int userId) async {
    try {
      final user = await _profileRepository.getUserById(userId);
      if (user != null) {
        _userProfile = user;
        notifyListeners(); // Cập nhật UI
        return user;
      } else {
        print("Failed to fetch user profile");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  // Hủy polling khi không cần nữa
  @override
  void dispose() {
    _pollingService.dispose(); //  Dừng polling khi Service bị hủy
    super.dispose();
  }

}
