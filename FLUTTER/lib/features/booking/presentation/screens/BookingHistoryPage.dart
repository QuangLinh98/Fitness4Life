import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../service/BookingRoomService.dart';

class BookingHistoryPage extends StatefulWidget {
  final int userId;

  BookingHistoryPage({required this.userId});

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Sử dụng callback này để chắc chắn gọi fetchBookingRooms sau khi widget được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi fetchBookingRooms() sau khi trang đã được render lần đầu
      final bookingService =  Provider.of<BookingRoomService>(context, listen: false).fetchBookingRooms(widget.userId);
      print('Booking service : $bookingService');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance History')),
      body: Consumer<BookingRoomService>(
        builder: (context, bookingService, child) {
          // Hiển thị loading khi dữ liệu đang được tải
          if (bookingService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Nếu không có dữ liệu booking
          if (bookingService.bookingHistory.isEmpty) {
            return Center(child: Text('No booking history available.'));
          }

          // Hiển thị danh sách các lớp học đã đăng ký
          return ListView.builder(
            itemCount: bookingService.bookingHistory.length,
            itemBuilder: (context, index) {
              final booking = bookingService.bookingHistory[index];

              // Định dạng bookingDate nếu là DateTime
              String formattedDate = booking.bookingDate != null
                  ? DateFormat('dd/MM/yyyy hh:mm a').format(booking.bookingDate!)
                  : 'N/A';

              return ListTile(
                title: Text(booking.roomName ?? 'N/A'), // Hiển thị tên phòng
                subtitle: Text(formattedDate),  // Hiển thị ngày giờ lớp
                trailing: Text(booking.status ?? 'No Status'), // Hiển thị trạng thái lớp
              );
            },
          );
        },
      ),
    );
  }
}
