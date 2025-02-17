import 'package:fitness4life/features/smart_deal/data/models/promotion/PromotionPointDTO.dart';
import 'package:fitness4life/features/smart_deal/data/models/promotion/UserPromotion.dart';

import '../../features/smart_deal/data/models/promotion/Point.dart';
import '../api_gateway.dart';

class PromotionRepository {
  final ApiGateWayService _apiGateWayService;

  PromotionRepository(this._apiGateWayService);

  Future<Point?> getPoint(int userId) async {
    try {
      final response = await _apiGateWayService.getData('/goal/userPoint/$userId');

      if (response.data != null && response.data['data'] != null) {
        try {
          Point userPoint = Point.fromJson(response.data['data']);
          return userPoint;
        } catch (e) {
          print("❌ Lỗi khi chuyển đổi JSON sang Point: $e");
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

  Future<List<UserPromotion>> getPromotionByIdOfUser(int userId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/promotionOfUser/$userId');
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        List<UserPromotion?> promotions = dataList.map((json) {
          try {
            UserPromotion promotion = UserPromotion.fromJson(json);
            return promotion;
          } catch (e) {
            print("❌ Lỗi chuyển đổi promotion all: $e");
            return null;
          }
        }).where((item) => item != null).toList();
        return promotions.cast<UserPromotion>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách UserPromotion: $e");
      throw Exception("Failed to fetch UserPromotion. Please try again later.");
    }
  }

  Future<List<PromotionPointDTO>> getAllPromotionPoint() async {
    try {
      final response = await _apiGateWayService.getData('deal/promotions/json/all');
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        List<PromotionPointDTO?> promotions = dataList.map((json) {
          try {
            PromotionPointDTO promotion = PromotionPointDTO.fromJson(json);
            return promotion;
          } catch (e) {
            print("❌ Lỗi chuyển đổi promotion all: $e");
            return null;
          }
        }).where((item) => item != null).toList();
        return promotions.cast<PromotionPointDTO>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách PromotionPointDTO: $e");
      throw Exception("Failed to fetch PromotionPointDTO. Please try again later.");
    }
  }

}