import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/config/constants.dart';
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
        title: const Center(
          child: Text('QR Code'),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (qrData != null && qrData!.qrCodeUrl != null && qrData!.qrCodeUrl!.isNotEmpty)
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: getFullImageUrl(qrData!.qrCodeUrl),
              width: 300,
              height: 300,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ],
        ),
      )
          : const Center(child: Text("No QR Code found for this booking")),
    );
  }
}
