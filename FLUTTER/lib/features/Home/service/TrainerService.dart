import 'package:fitness4life/api/Dashboard_Repository/TrainerRepository.dart';
import 'package:fitness4life/features/Home/data/Trainer.dart';
import 'package:flutter/material.dart';

class TrainerService extends ChangeNotifier{
  final TrainerRepository _trainerRepository;
  List<Trainer> trainers = [];
  bool isLoading = false;

  TrainerService(this._trainerRepository);

  //Get All data
  Future<void> fetchTrainers() async {
    isLoading = true;
    notifyListeners();
    try{
       trainers = await _trainerRepository.getAllTrainers();
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