package fpt.aptech.bookingservice.controller;

import fpt.aptech.bookingservice.helpers.ApiResponse;
import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.service.WorkoutPackageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/booking")
@RequiredArgsConstructor
public class ManagerController {
    private final WorkoutPackageService workoutPackageService;

    //======================= WORKOUT PACKAGE ============================
    @PostMapping("/package/add")
    public ResponseEntity<?> addPackage(@Valid @RequestBody WorkoutPackage workoutPackage, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            WorkoutPackage newPackage = workoutPackageService.addWorkoutPackage(workoutPackage);
            return ResponseEntity.status(201).body(ApiResponse.success(newPackage, "Add package successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/package/update/{id}")
    public ResponseEntity<?> editPackage(@PathVariable int id, @Valid @RequestBody WorkoutPackage workoutPackage, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            WorkoutPackage updatePackage = workoutPackageService.updateWorkoutPackage(id, workoutPackage);
            return ResponseEntity.status(201).body(ApiResponse.success(updatePackage, "Update Package successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("WorkoutPackageNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Package not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server " + e.getMessage()));
        }
    }

    @DeleteMapping("/package/delete/{id}")
    public ResponseEntity<?> deletePackage(@PathVariable int id) {
        try {
            workoutPackageService.deleteWorkoutPackage(id);
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Delete package successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("WorkoutPackageNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Package not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }
}