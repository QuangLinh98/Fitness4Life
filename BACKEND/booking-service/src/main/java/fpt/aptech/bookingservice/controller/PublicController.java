package fpt.aptech.bookingservice.controller;

import fpt.aptech.bookingservice.helpers.ApiResponse;
import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.service.WorkoutPackageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/booking")
@RequiredArgsConstructor
public class PublicController {
    private final WorkoutPackageService workoutPackageService;

    //======================= WORKOUT PACKAGE ============================
    @GetMapping("/packages")
    public ResponseEntity<?> getAllPackage() {
        try {
            List<WorkoutPackage> pakages =  workoutPackageService.getAllData();
            return ResponseEntity.status(200).body(ApiResponse.success(pakages, "Get All Package successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("/package/{id}")
    public ResponseEntity<?> getPackageById(@PathVariable int id) {
        try {
            WorkoutPackage wPackage = workoutPackageService.getWorkoutPackageById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(wPackage, "Get package successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("PackageNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Package not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }
}
