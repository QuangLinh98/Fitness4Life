

import 'package:flutter/cupertino.dart';

import '../../features/smartDeal/data/models/promotion/Point.dart';
import '../api_gateway.dart';

class PromotionRepository{

  final ApiGateWayService _apiGateWayService;

  PromotionRepository(this._apiGateWayService);

  Future<Point?> getAllPoint(int userId) async {
    try {
      final response = await _apiGateWayService.getData('/goal/userPoint/$userId');

      if (response.data != null && response.data['data'] != null) {
        try {
          Point userPoin = Point.fromJson(response.data['data']);
          return userPoin;
        } catch (e) {
          print("❌ Lỗi chuyển đổi UserPoinDTO: $e");
          return null;
        }
      } else {
        throw Exception("Invalid response structure or no data found.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy điểm của user $userId: $e");
      throw Exception("Failed to fetch user points. Please try again later.");
    }
  }






}