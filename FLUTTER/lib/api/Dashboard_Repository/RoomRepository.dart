import 'package:fitness4life/api/api_gateway.dart';
import 'package:fitness4life/features/Home/data/Room.dart';

class RoomRepository{
  final ApiGateWayService _apiGateWayService;

  RoomRepository(this._apiGateWayService);

  //Lấy danh sách Room
  Future<List<Room>> getAllRooms() async {
    try{
      final response = await _apiGateWayService.getData('/dashboard/rooms');
      return (response.data['data'] as List)
          .map((json) => Room.fromJson(json))
          .toList();
    }
    catch(e) {
      print("Error fetching rooms: $e");
      throw Exception("Error fetching rooms: $e");
    }
  }
}