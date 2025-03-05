import 'package:fitness4life/api/Booking_Repository/BookingRoomRepository.dart';
import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:fitness4life/features/booking/data/BookingRoom.dart';
import 'package:flutter/cupertino.dart';

class BookingRoomService extends ChangeNotifier {
  final BookingRoomRepository _bookingRoomRepository;
  final RoomRepository _roomRepository;

  List<BookingRoom> bookedRooms = [];
  List<BookingRoom> bookingHistory = [];
  bool isLoading = false;

  BookingRoomService(this._bookingRoomRepository, this._roomRepository);

  //Xử lý booking room
  Future<bool> bookingRoom(int roomId , int userId) async {
    print('Có lọt vào service hay không ');
    isLoading = true;
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

  //Xử lý lấy room theo userId để hiển thị trang ClassScreen
  Future<void> fetchBookedRooms(int userId) async {
    isLoading = true;
    try {
      bookedRooms = await _bookingRoomRepository.getBookedRooms(userId);
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Error fetching booked rooms: $e");
    }
  }

  //Xử lý lấy room theo userId để hiển thị trang ClassScreen
  Future<void> fetchBookingRooms(int userId) async {
    isLoading = true;
    try {
      bookingHistory = await _bookingRoomRepository.fetchBookingHistory(userId);
      print('Response Booking : $bookingHistory');
      notifyListeners(); // Cập nhật UI
    } catch (e) {
      print("Error fetching booking rooms: $e");
    }
  }

  //Xử lý cancel booking room
  Future<void> cancelBooking(int id) async {
    try {
       await _bookingRoomRepository.cancelBooking(id);

       // Loại bỏ phòng đã hủy khỏi danh sách hiện tại
       bookedRooms.removeWhere((room) => room.id == id);

       // Tìm phòng tương ứng và giảm số ghế trống
       final room = await _roomRepository.getRoomById(id);
       if (room != null) {
         room!.availableseats = (room.availableseats ?? 0) - 1;
         await _roomRepository.updateRoom(id, room);
       } else {
         print("Room with ID $id not found.");
       }

       // Cập nhật lại danh sách phòng đã đặt
       await _roomRepository.getAllRooms();

       notifyListeners();

       // Cập nhật giao diện người dùng
       notifyListeners();
    } catch (e) {
      print("Error fetching booked rooms: $e");
    }
  }
}