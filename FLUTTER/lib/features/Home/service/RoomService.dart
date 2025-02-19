import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:flutter/material.dart';

class RoomService extends ChangeNotifier {
  final RoomRepository _roomRepository;
  List<Room> rooms = [];
  Room? room;
  bool isLoading = false;

  RoomService(this._roomRepository);

  //Get All data
  Future<void> fetchRooms() async {
    isLoading = true;
    notifyListeners();
    try{
      rooms = await _roomRepository.getAllRooms();
      // Update availableSeats for each room
      // for (var room in rooms) {
      //   room.availableseats = (room.capacity! - room.bookedSeats).toInt(); // Update availableSeats based on booking
      // }
    }
    catch(e) {
      print("Error fetching room: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRoom(int roomId, Room updatedRoom) async {
    try {
      await _roomRepository.updateRoom(roomId, updatedRoom);
      print("Room updated successfully: ID $roomId");
    } catch (e) {
      print("Error updating room: $e");
      throw Exception("Error updating room: $e");
    }
  }
  
  
  Future<void> getRoomById(int roomId) async {
    isLoading = true;
    notifyListeners();
    try{
      room = await _roomRepository.getRoomById(roomId);
    }
    catch(e) {
      print("Error fetching room: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
