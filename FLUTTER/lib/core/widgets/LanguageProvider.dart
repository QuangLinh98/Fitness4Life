import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  bool _isVietnamese = false;

  bool get isVietnamese => _isVietnamese;

  void toggleLanguage() {
    _isVietnamese = !_isVietnamese;
    notifyListeners();
  }
}
