import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:flutter/material.dart';

class RoomService extends ChangeNotifier {
  final RoomRepository _roomRepository;
  List<Room> rooms = [];
  List<Room> packageRooms = [];
  Room? room;
  bool isLoading = false;

  RoomService(this._roomRepository);

  //Get All data
  Future<void> fetchRooms() async {
    isLoading = true;
    notifyListeners();
    try{
      rooms = await _roomRepository.getAllRooms();
    }
    catch(e) {
      print("Error fetching room: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Get room By Package
  Future<void> fetchRoomsByPackage(int packageId) async {
    isLoading = true;
    notifyListeners();
    try{
      packageRooms = await _roomRepository.getAllRoomsByPackage(packageId);
    }
    catch(e) {
      print("Error fetching room by packageId: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Hàm kiểm tra phòng có trong gói tập không
  bool isRoomInPackage(int roomId) {
    return packageRooms.any((room) => room.id == roomId);
  }

  Future<void> fetchRoomsByBranchId(int branchId) async {
    isLoading = true;
    notifyListeners();
    try {
      rooms = await _roomRepository.getRoomsByBranchId(branchId);
    } catch (e) {
      print("Error fetching rooms by branchId: $e");
    } finally {
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
