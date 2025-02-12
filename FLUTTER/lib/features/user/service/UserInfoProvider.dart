import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  String? _userName;
  int? _userId;
  int _userPoint = 0;

  String? get userName => _userName;
  int? get userId => _userId;
  int get userPoint => _userPoint;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void setUserInfo(String name, int id) {
    _userName = name;
    _userId = id;
    notifyListeners();
  }

  void setUserPoint(int point) {
    _userPoint = point;
    notifyListeners();
  }

  void logout() {
    _userName = null;
    _userId = null;
    _userPoint = 0;
    notifyListeners();
  }


}