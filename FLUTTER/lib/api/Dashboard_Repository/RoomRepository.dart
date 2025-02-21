import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/Home/data/Room.dart';

class RoomRepository{
  final ApiGateWayService _apiGateWayService;

  RoomRepository(this._apiGateWayService);

  //Lấy danh sách Room
  Future<List<Room>> getAllRooms() async {
    try{
      final response = await _apiGateWayService.getData('/dashboard/rooms');
      print('Response Room : ${response.data}');
      return (response.data['data'] as List)
          .map((json) => Room.fromJson(json))
          .toList();
    }
    catch(e) {
      throw Exception("Error fetching rooms: $e");
    }
  }

  Future<Room> getRoomById(int roomId) async {
    try{
      final response = await _apiGateWayService.getData('/dashboard/room/$roomId');
      print('Response Room by Id : ${response.data}');
      if (response.statusCode == 200) {
        final roomData = response.data; // Dữ liệu trả về từ API
        // Chuyển đổi dữ liệu JSON thành đối tượng Room
        return Room.fromJson(roomData);
      } else {
        throw Exception('Failed to load room data');
      }
    }
    catch(e) {
      throw Exception("Error fetching room by  roomId: $e");
    }
  }

  // Cập nhật thông tin phòng sau khi thay đổi ghế trống
  Future<void> updateRoom(int roomId, Room updatedRoom) async {
    try {
      final response = await _apiGateWayService.putData(
        '/dashboard/room/update/$roomId',
          data: updatedRoom.toJson(), // Chuyển đổi đối tượng Room thành JSON
      );

      print("Room updated successfully: $response");
    } catch (e) {
      print("Error updating room: $e");
      throw Exception("Error updating room: $e");
    }
  }

}