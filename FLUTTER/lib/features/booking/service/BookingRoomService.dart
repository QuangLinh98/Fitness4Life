import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:fitness4life/features/booking/data/BookingRoom.dart';
import 'package:flutter/cupertino.dart';

class BookingRoomService extends ChangeNotifier {
  final BookingRoomRepository _bookingRoomRepository;

  List<BookingRoom> bookedRooms = [];

  BookingRoomService(this._bookingRoomRepository);

  //Xử lý booking room
  Future<bool> bookingRoom(int roomId , int userId) async {
    try{
        await _bookingRoomRepository.bookRoom(roomId, userId);
        //notifyListeners();
        await fetchBookedRooms(userId); // Làm mới danh sách sau khi đặt phòng
        return true;
    }
    catch(e) {
      print("Error booking room: $e");
      throw Exception("Error booking room: $e");
    }
  }

  //Xử lý lấy room theo userId
  Future<void> fetchBookedRooms(int userId) async {
    try {
      bookedRooms = await _bookingRoomRepository.getBookedRooms(userId);
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Error fetching booked rooms: $e");
    }
  }

  //Xử lý cancel booking room
  Future<void> cancelBooking(int id) async {
    try {
       await _bookingRoomRepository.cancelBooking(id);

       // Loại bỏ phòng đã hủy khỏi danh sách hiện tại
       bookedRooms.removeWhere((room) => room.id == id);

       // Cập nhật giao diện người dùng
       notifyListeners();
    } catch (e) {
      print("Error fetching booked rooms: $e");
    }
  }
}