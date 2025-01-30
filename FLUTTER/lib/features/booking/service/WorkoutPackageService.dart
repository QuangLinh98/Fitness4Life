import 'package:fitness4life/api/Booking_Repository/WorkoutPackageRepository.dart';
import 'package:fitness4life/features/booking/data/WorkoutPackage.dart';
import 'package:flutter/cupertino.dart';

class WorkoutPackageService extends ChangeNotifier{
  final WorkoutPackageRepository _packageRepository;
  WorkoutPackageService(this._packageRepository);

  List<WorkoutPackage> _workoutPackages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkoutPackage> get workoutPackages => _workoutPackages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkoutPackage() async {
    _isLoading = true;
    notifyListeners();
    try{
      _workoutPackages = await _packageRepository.fetchWorkoutPackages();
      _errorMessage = null;
    }catch (e) {
      _errorMessage = "Failed to load packages: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}