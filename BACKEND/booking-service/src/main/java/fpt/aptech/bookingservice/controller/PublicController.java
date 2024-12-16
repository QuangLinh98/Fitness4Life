package fpt.aptech.bookingservice.controller;

import fpt.aptech.bookingservice.dtos.WorkoutPackageDTO;
import fpt.aptech.bookingservice.helpers.ApiResponse;
import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.service.BookingRoomService;
import fpt.aptech.bookingservice.service.WorkoutPackageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/booking")
@RequiredArgsConstructor
public class PublicController {
    private final WorkoutPackageService workoutPackageService;
    private final BookingRoomService bookingRoomService;

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
            WorkoutPackageDTO wPackage = workoutPackageService.getWorkoutPackageById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(wPackage, "Get package successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("PackageNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Package not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PostMapping("/package/{ids}")
    public ResponseEntity<?> addPackage(@PathVariable List<Integer> ids) {
        try {
            List<WorkoutPackageDTO> workoutPackageDTOS = workoutPackageService.getWorkoutPackagesByIds(ids);
            return ResponseEntity.status(200).body(ApiResponse.success(workoutPackageDTOS, "Get package successfully"));

        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= BOOKING ROOM ============================
    @GetMapping("/bookingRooms")
    public ResponseEntity<?> getAllBookingRoom() {
        try {
            List<BookingRoom> bookings =  bookingRoomService.getAllBookingRoom();
            return ResponseEntity.status(200).body(ApiResponse.success(bookings, "Get All booking successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= QR CODE ============================
//    @GetMapping("/qrCode/{qrCodeId}")
//    public ResponseEntity<?> getBookingByQRCode(@PathVariable int qrCodeId) {
//        try {
//            BookingRoom bookings =  bookingRoomService.getAllBookingRoom();
//            return ResponseEntity.status(200).body(ApiResponse.success(bookings, "Get All booking successfully"));
//        }
//        catch (Exception e) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
//        }
//    }
}
