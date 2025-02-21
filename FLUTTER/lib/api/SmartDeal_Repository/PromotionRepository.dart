import 'package:fitness4life/features/smart_deal/data/models/promotion/PromotionOfUserDTO.dart';
import 'package:fitness4life/features/smart_deal/data/models/promotion/PromotionPointDTO.dart';
import 'package:flutter/cupertino.dart';

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


  Future<PromotionOfUserDTO> findCode(String promotionCode,int userId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/promotionOfUser/$promotionCode/$userId');
      // print("log data findCode ${response.data}");
      if (response.data != null && response.data['data'] != null) {
        try {
          PromotionOfUserDTO code = PromotionOfUserDTO.fromJson(response.data['data']);
          // print("find code = $code");
          return code;
        } catch (e) {
          print("❌ Lỗi chuyển đổi PromotionOfUserDTO one: $e");
          return response.data;
        }
      } else {
        throw Exception("Invalid response structure or no data found.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy promotion $promotionCode and $userId: $e");
      throw Exception("Failed to fetch promotion. Please try again later.");
    }
  }



  Future<String> UsedPromotionCode(int userId, String promotionCode) async {
    try {
      final response = await _apiGateWayService.postData('/deal/promotionOfUser/usedCode/$userId?promotionCode=$promotionCode');
      if (response.data != null) {
        print("log data UsedPromotionCode ${response.data}");
        return response.data;
      } else {
        throw Exception("Invalid response structure UsedPromotionCode.");
      }
    } catch (e) {
      throw Exception("Failed to fetch UserPromotion. Please try again later.");
    }
  }

  Future<List<PromotionOfUserDTO>> getPromotionUser(int userId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/promotionOfUser/getPromotionUser/$userId');

      // debugPrint("lấy được data từ api ko ta:  ${response.data}");
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        List<PromotionOfUserDTO?> promotionOfUsers= dataList.map((json) {
          try {
            PromotionOfUserDTO promotion = PromotionOfUserDTO.fromJson(json);
            return promotion;
          } catch (e) {
            print("❌ Lỗi chuyển đổi promotion all: $e");
            return null;
          }
        }).where((item) => item != null).toList();
        return promotionOfUsers.cast<PromotionOfUserDTO>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách PromotionOfUserDTO: $e");
      throw Exception("Failed to fetch PromotionOfUserDTO. Please try again later.");
    }
  }

  Future<List<PromotionPointDTO>> getPromotionInJson() async {
    try {
      final response = await _apiGateWayService.getData('/deal/promotions/json/all');

      debugPrint("lấy được data từ api ko ta:  ${response.data}");
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        List<PromotionPointDTO?> promotions= dataList.map((json) {
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
      print("❌ Lỗi khi lấy danh sách PromotionOfUserDTO: $e");
      throw Exception("Failed to fetch PromotionOfUserDTO. Please try again later.");
    }
  }

  Future<bool> usedPointChangeCode(int userId,int point, String promotionId) async {
    try {
      final response = await _apiGateWayService.postData('/deal/promotionOfUser/usedPointChangCode/$userId?point=$point&promotionId=$promotionId');
      if (response.data != null) {
        print("log data usedPointChangeCode ${response.data}");
        return true;
      } else {
        throw Exception("Invalid response structure usedPointChangeCode.");
      }
    } catch (e) {
      throw Exception("Failed to fetch usedPointChangeCode. Please try again later.");
    }
  }

}