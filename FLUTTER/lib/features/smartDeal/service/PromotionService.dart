import 'package:fitness4life/api/SmartDeal_Repository/PromotionRepository.dart';
import 'package:fitness4life/features/smartDeal/data/models/promotion/Point.dart';
import 'package:flutter/cupertino.dart';

class PromotionService extends ChangeNotifier {
  final PromotionRepository _promotionRepository;

  PromotionService(this._promotionRepository);
  bool isLoading = false;


  Future<Point?> fetchPoint(int userId) async {
    isLoading = true;
    notifyListeners();
    try {
      Point? point = await _promotionRepository.getAllPoint(userId);
      return point;
    } catch (e) {
      print("Error fetching point: $e");
      return null;  // Trả về 0 nếu có lỗi
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}