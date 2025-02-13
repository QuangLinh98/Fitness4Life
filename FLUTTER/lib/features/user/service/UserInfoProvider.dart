import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  String? _userName;
  int? _userId;


  String? get userName => _userName;
  int? get userId => _userId;

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

  void logout() {
    _userName = null;
    _userId = null;
    notifyListeners();
  }
}