import 'package:fitness4life/api/Dashboard_Repository/BranchRepository.dart';
import 'package:fitness4life/features/Home/data/Branch.dart';
import 'package:flutter/material.dart';

class BranchService extends ChangeNotifier{
  final BranchRepository _branchRepository;
  List<Branch> branchs = [];
  bool isLoading = false;

  BranchService(this._branchRepository);

  //Get All data
  Future<void> fetchBranchs() async {
    isLoading = true;
    notifyListeners();
    try{
      branchs = await _branchRepository.getAllBranchs();
    }
    catch(e) {
      print("Error fetching branchs: $e");
    }
    finally {
      isLoading = false;
      notifyListeners();
    }
  }
}