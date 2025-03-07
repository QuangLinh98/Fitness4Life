import 'package:fitness4life/api/Booking_Repository/PaypalRepository.dart';
import 'package:flutter/cupertino.dart';

class PaypalService extends ChangeNotifier {
  final PaypalRepository _paypalRepository;

  PaypalService(this._paypalRepository);

  /// **📌 Bước 1: Lấy Access Token**
  Future<String?> getAccessToken() async {
    return await _paypalRepository.getAccessToken();
  }

  /// **📌 Bước 2: Tạo thanh toán trên PayPal**
  Future<String?> createPayment(double amount, int userId, int packageId , discountCode) async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print("❌ Không lấy được Access Token!");
      return null;
    }

    final response = await _paypalRepository.createPayment(accessToken, amount, userId, packageId,discountCode);
    print("📥 Response Data: $response");

    // ✅ Cách mới để lấy approvalUrl
    if (response != null && response.containsKey("approvalUrl")) {
      print("✅ Lấy được URL Thanh Toán: ${response["approvalUrl"]}");
      return response["approvalUrl"];
    }

    print("❌ Không tìm thấy URL thanh toán trong response!");
    return null;
  }

  /// **📌 Bước 3: Xác nhận thanh toán**
  Future<bool> executePayment(String paymentId, String payerId, String paypalToken) async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) return false;
    return await _paypalRepository.executePayment(accessToken, paymentId, payerId, paypalToken);
  }
}
