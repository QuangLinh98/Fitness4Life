
import 'package:fitness4life/api/SmartDeal_Repository/PromotionRepository.dart';
import 'package:fitness4life/features/smart_deal/data/models/promotion/Point.dart';
import 'package:fitness4life/features/smart_deal/data/models/promotion/UserPromotion.dart';
import 'package:flutter/cupertino.dart';

class PromotionService extends ChangeNotifier {
  final PromotionRepository _promotionRepository;

  PromotionService(this._promotionRepository);
  List<UserPromotion> promotions = [];

  bool isLoading = false;
  bool isFetchingSingle = false; // Biến trạng thái khi lấy 1 câu hỏi

  Future<Point?> fetchPoint(int userId) async {
    isFetchingSingle = true;
    notifyListeners();
    try {
      Point? point = await _promotionRepository.getPoint(userId);
      return point;
    } catch (e) {
      print("❌ Lỗi khi lấy dữ liệu điểm: $e");
      return null;
    } finally {
      isFetchingSingle = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPromotionById(int userId) async {
    isLoading = true;
    notifyListeners();
    try {
      promotions = await _promotionRepository.getPromotionByIdOfUser(userId);
      debugPrint("Fetched promotions $userId: $promotions");
    } catch (e) {
      print("Error fetching promotions by ID: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}