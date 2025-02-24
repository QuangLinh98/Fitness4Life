import 'package:flutter/material.dart';

class PageManagerProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void updateIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // Thông báo UI cập nhật lại
  }
}
