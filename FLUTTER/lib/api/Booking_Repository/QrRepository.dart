
import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/booking/data/QR.dart';

class QrRepository {
  final ApiGateWayService _apiGateWayService;
  QrRepository(this._apiGateWayService);

  Future<QR> getQrByBookingRoomId(int bookingRoomId) async {
    try {
      final response = await _apiGateWayService.getData("/booking/qrCode/$bookingRoomId");
      print("Response data: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return QR.fromJson(data); // Chuyển đổi JSON sang QRCode model
      } else {
        throw Exception('Failed to fetch QR Code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching QR Code: $e");
      throw Exception("Error fetching QR Code: $e");
    }
  }
}