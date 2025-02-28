import 'dart:convert';

import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/notification/data/Notify.dart';

class NotifyRepository {
  final ApiGateWayService _apiGateWayService;

  NotifyRepository(this._apiGateWayService);

  //Hàm xử lý lấy Goal theo UserId
  Future<List<Notify>> getNotifyByUserId (int userId) async {
    try{
      final response = await _apiGateWayService.getData('/notify/user/$userId');
      print('Notify Response to server : ${response.data}');
      // Kiểm tra cấu trúc JSON trả về
      if (response.data != null && response.data is List) {
        return (response.data as List).map((item) {
          // Parse JSON thành Goal
          return Notify.fromJson(item);
        }).toList();
      } else {
        throw Exception("Invalid data structure: Expected a List.");
      }
    }catch (e, stackTrace) {
      print("Error fetching goals: $e");
      print("StackTrace: $stackTrace");
      throw Exception("Error fetching goals: $e");
    }
  }
}