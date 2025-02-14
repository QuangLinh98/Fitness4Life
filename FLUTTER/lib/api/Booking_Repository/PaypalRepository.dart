import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fitness4life/api/api_gateway.dart';

class PaypalRepository {
  final ApiGateWayService _apiGateWayService;

  PaypalRepository(this._apiGateWayService);

  final String clientId = "Ad3CeOGogJLfUQftP85q_r8FMM_WfxvrAyERScXzFJ-iVjEMWkirrWvGGwJ3YUnDio5jmQIOr30TTeNJ"; // Thay bằng Client ID của bạn
  final String secret = "EA-DEUOO8mRlgbbwWN6F4BZ6sl1J93EPvZPd78MPuxvkxPQAqE0Wqc2rJz6_N8tVvtCHYsTPTLV4VRcC"; // Thay bằng Secret Key của bạn
  final String paypalUrl = "https://api.sandbox.paypal.com";

  /// **📌 Lấy Access Token từ PayPal**
  Future<String?> getAccessToken() async {
    try {
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('$clientId:$secret'));

      final response = await Dio().post(
        "$paypalUrl/v1/oauth2/token", // ✅ Gọi API trực tiếp
        data: {
          "grant_type": "client_credentials",
        },
        options: Options(
          headers: {
            'Authorization': basicAuth, // ✅ Basic Auth cho PayPal
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Lấy được Access Token: ${response.data["access_token"]}");
        return response.data["access_token"];
      } else {
        print("❌ Lỗi khi lấy Access Token: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy Access Token: $e");
    }
    return null;
  }

  /// **📌 Tạo thanh toán trên PayPal**
  Future<Map<String, dynamic>?> createPayment(String accessToken, double amount, int userId, int packageId , {double? discountedAmount}) async {
    double finalAmount = discountedAmount ?? amount;  //Nếu áp mã giảm giá
    print("📌 Total Amount Sent to PayPal: \$${finalAmount.toStringAsFixed(2)}");

    final requestBody = {
      "packageId": packageId, // Thêm gói ID vào request
      "userId": userId, // Thêm userId vào request
      "description": "Membership Subscription",
      "cancelUrl": "fitness4life://paypal_cancel",
      "successUrl": "fitness4life://paypal_success",
      "currency": "USD",
      "intent": "sale",
      "transactions": [
        {
          "amount": {
            "total": finalAmount.toStringAsFixed(2), // Định dạng số tiền chính xác
            "currency": "USD"
          },
          "description": "Payment for Gym Membership"
        }
      ],
      "redirect_urls": {
        "return_url": "fitness4life://paypal_success",
        "cancel_url": "fitness4life://paypal_cancel"
      }
    };

    print("📌 Request Body gửi đến PayPal:");
    print(jsonEncode(requestBody));

    try {
      final response = await _apiGateWayService.postData(
        '/paypal/pay',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("❌ Lỗi tạo thanh toán: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("❌ Lỗi khi tạo thanh toán: $e");
    }
    return null;
  }

  /// **📌 Xác nhận thanh toán**
  Future<bool> executePayment(String accessToken, String paymentId, String payerId , String paypalToken) async {
    try {
      Response response = await _apiGateWayService.postData(
        "/paypal/success?paymentId=$paymentId&token=$paypalToken&PayerID=$payerId",
        // data: {
        //   "paymentId": paymentId,
        //   "payer_id": payerId
        // },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Thanh toán thành công!");
        return true;
      } else {
        print("❌ Lỗi xác nhận thanh toán: ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi khi xác nhận thanh toán: $e");
      return false;
    }
  }
}
