import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/booking/data/BookingRoom.dart';

class BookingRoomRepository {
    final ApiGateWayService _apiGateWayService;

    BookingRoomRepository(this._apiGateWayService);

    //Xử lý booking room
    Future<bool> bookRoom(int roomId, int userId) async {
      print('Có lọt vào không ');
    try {
        final url = '/booking/bookingRoom/add';

        // Chuẩn bị payload
        final payload = {
          "roomId": roomId,
          "userId": userId,
        };

        // Gửi request POST
        final response = await _apiGateWayService.postData(url, data: payload);
        print('Request gửi xuống backend : ${response.data}');
      // Kiểm tra statusCode
        if (response.statusCode == 201) {
          return true;
        } else {
          final errorMessage = response.data['message'];
          throw Exception("Failed to book room: $errorMessage");
        }
      } catch (e) {
        print("Error booking room: $e");
        throw Exception("Error booking room: $e");
      }
    }

    //Hiển thị trang booked room
    Future<List<BookingRoom>> getBookedRooms(int userId) async {
      try{
        final response = await _apiGateWayService.getData("/booking/bookingRooms/history/$userId");
        return (response.data['data'] as List)
            .map((json) => BookingRoom.fromJson(json))
            .toList();
      }
      catch (e) {
        print("Error get booked room: $e");
        throw Exception("Error booking room: $e");
      }
    }

    //Hiển thị lịch sử booking của user
    Future<List<BookingRoom>> fetchBookingHistory(int userId) async {
      try {
        final response = await _apiGateWayService.getData("/booking/history/$userId");
        print('Booking History : ${response.data}');

        // Kiểm tra nếu response.data['data'] là null hoặc không phải List
        if (response.data['data'] != null && response.data['data'] is List) {
          return (response.data['data'] as List)
              .map((json) => BookingRoom.fromJson(json))
              .toList();
        } else {
          // Trả về danh sách trống hoặc xử lý khi không có dữ liệu
          return [];
        }
      } catch (e) {
        print("Error get history booking room: $e");
        throw Exception("Error booking room: $e");
      }
    }


    Future<void> cancelBooking(int id) async {
      try {
        // Gửi yêu cầu hủy đặt phòng tới API
        final response = await _apiGateWayService.putData("/booking/cancelBookingRoom/$id");

      } catch (e) {
        // Xử lý lỗi nếu xảy ra
        print("Error canceling booking: $e");
        throw Exception("Error canceling booking: $e");
      }
    }

}