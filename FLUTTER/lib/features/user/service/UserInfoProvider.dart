import 'package:dio/dio.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/User_Repository/ProfileRepository.dart';
import '../../../api/api_gateway.dart';
import '../data/models/UserResponseDTO.dart';

class UserInfoProvider extends ChangeNotifier {
  String? _userName;
  int? _userId;
  int? _userPoint = 0;
  int? _workoutPackageId = 0;

  final ProfileService _profileService;

  UserInfoProvider(this._profileService) {
    loadWorkoutPackageId().then((_) {
      if (_userId != null) {
        fetchUserInfo(); // Tự động gọi API khi app khởi động
      }
    });
  }


  String? get userName => _userName;
  int? get userId => _userId;
  int? get userPoint => _userPoint;
  int? get workoutPackageId => _workoutPackageId;

  /// ==================== 🟢 HÀM LƯU DỮ LIỆU 🟢 ====================
  // Lưu workoutPackageId vào SharedPreferences
  Future<void> _saveWorkoutPackageId(int packageId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workoutPackageId', packageId);
    print("💾 Đã lưu workoutPackageId: $packageId");
  }

  // Load workoutPackageId từ SharedPreferences khi app khởi động
  Future<void> loadWorkoutPackageId() async {
    final prefs = await SharedPreferences.getInstance();
    _workoutPackageId = prefs.getInt('workoutPackageId') ?? 0;
    print("📥 WorkoutPackageId đã load: $_workoutPackageId");
    notifyListeners();
  }

  /// ==================== 🔄 CẬP NHẬT THÔNG TIN 🔄 ====================

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void setUserPoint(int point) {
    _userPoint = point;
    notifyListeners();
  }

  // Cập nhật workoutPackageId và lưu vào SharedPreferences
  void setWorkoutPackageId(int packageId) {
    _workoutPackageId = packageId;
    _saveWorkoutPackageId(packageId);
    notifyListeners();
  }

  void setUserInfo(String name, int id) async {
    print("🛠 Gọi setUserInfo với name: $name, id: $id");
    _userName = name;
    _userId = id;
    _userPoint = 0;
    await fetchUserInfo();
    notifyListeners();
  }

  /// ==================== 📲 FETCH DỮ LIỆU TỪ API 📲 ====================
  Future<void> fetchUserInfo() async {
    print("🔍 Kiểm tra UserID trước khi gọi API: $_userId"); // Debug trước khi gọi API

    if (_userId == null) {
      print("⚠️ UserID is null, không gọi API");
      return;
    }
    try {
      UserResponseDTO? user = await _profileService.getUserById(_userId!);
      print('User Response : $user');
      if (user != null) {
        print("API Response: ${user.toJson()}");
        _userName = user.fullName;
        _workoutPackageId = user.workoutPackageId;

        // 🔑 Lưu workoutPackageId sau khi fetch
        await _saveWorkoutPackageId(_workoutPackageId!);
        print("Workout Package ID sau cập nhật: $_workoutPackageId");
        notifyListeners();
      }else{
        print('User null');
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  void logout() async {
    _userName = null;
    _userId = null;
    _workoutPackageId = 0;

    // Xóa workoutPackageId khỏi SharedPreferences khi logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workoutPackageId');
    print("🗑 WorkoutPackageId đã bị xóa sau khi logout.");
    notifyListeners();
  }
}