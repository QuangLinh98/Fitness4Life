import 'package:fitness4life/features/booking/service/QrService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/booking/data/QR.dart';
import 'package:fitness4life/api/Booking_Repository/QrRepository.dart';
import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';


class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  QR? qrData; // Biến lưu trữ thông tin QR
  bool isLoading = true; // Trạng thái chờ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Gọi getQrByBookingRoomId
      final qrService = Provider.of<QrService>(context, listen: false);
      final fetchedQrData = await qrService.getQrByBookingRoomId(widget.bookingId);
      if (fetchedQrData != null) {
        setState(() {
          qrData = fetchedQrData; // Lưu dữ liệu QR
          isLoading = false;      // Ngừng trạng thái chờ
        });
      } else {
        setState(() {
          isLoading = false; // Ngừng trạng thái chờ nếu không có dữ liệu
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("This is booking detail"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị trạng thái chờ
          : qrData != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Booking ID: ${widget.bookingId}"),
            const SizedBox(height: 16),
            Image.network(
              qrData!.qrCodeUrl, // Hiển thị mã QR từ URL
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) => const Text("Failed to load QR code"),
            ),
          ],
        ),
      )
          : const Center(
        child: Text("No QR Code found for this booking"),
      ),
    );
  }
}
