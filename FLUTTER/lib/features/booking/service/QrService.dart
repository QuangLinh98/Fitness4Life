import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/features/booking/data/BookingRoom.dart';
import 'package:fitness4life/features/booking/data/QR.dart';
import 'package:flutter/cupertino.dart';

class QrService extends ChangeNotifier {
  final BookingRoomRepository _bookingRoomRepository;
  final QrRepository _qrRepository;

  QrService(this._qrRepository,this._bookingRoomRepository);

  Future<QR?> getQrByBookingRoomId(int bookingRoomId) async {
    try {
      QR qrCode = await _qrRepository.getQrByBookingRoomId(bookingRoomId);
      return qrCode;
    } catch (e) {
      print("Error fetching QR code for bookingRoomId $bookingRoomId: $e");
      return null;
    }
  }
}