import 'dart:async';
import 'package:flutter/material.dart';

class PollingService extends ChangeNotifier {
  Timer? _timer;
  final Function _fetchFunction;
  final int _intervalSeconds;

  PollingService({required Function fetchFunction, int intervalSeconds = 5})
      : _fetchFunction = fetchFunction,
        _intervalSeconds = intervalSeconds;

  void startPolling() {
    stopPolling(); // Hủy polling cũ nếu có
    _timer = Timer.periodic(Duration(seconds: _intervalSeconds), (_) async {
      await _fetchFunction(); // Gọi API cập nhật dữ liệu
      notifyListeners();
      print("✅ Data updated, UI should refresh now!");
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
