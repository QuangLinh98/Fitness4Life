import 'package:fitness4life/api/Dashboard_Repository/RoomRepository.dart';
import 'package:fitness4life/features/Home/data/Room.dart';
import 'package:flutter/material.dart';

class RoomService extends ChangeNotifier {
  final RoomRepository _roomRepository;
  List<Room> rooms = [];
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
      print("Error fetching trainers: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
