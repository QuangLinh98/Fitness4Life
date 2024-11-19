package fpt.aptech.dashboardservice.controller;

import fpt.aptech.dashboardservice.dtos.*;
import fpt.aptech.dashboardservice.helpers.ApiResponse;
import fpt.aptech.dashboardservice.models.*;
import fpt.aptech.dashboardservice.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class ManagerController {
    private final ClubService clubService;
    private final BranchService branchService;
    private final TrainerService trainerService;
    private final RoomService roomService;
    private final WorkoutPackageService workoutPackageService;

    //======================= CLUB ============================
    @PostMapping("/club/add")
    public ResponseEntity<?> saveClub(@Valid @RequestBody ClubDTO clubDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Club newClub = clubService.addClub(clubDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newClub, "Create a new Club successfully"));
        } catch (Exception e) {
            if (e.getMessage().contains("ContactPhoneAlreadyExists")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Contact phone already exists"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/club/update/{id}")
    public ResponseEntity<?> updateClub(@PathVariable int id, @Valid @RequestBody ClubDTO clubDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Club updatedClub = clubService.updateClub(id, clubDTO);
            return ResponseEntity.status(200).body(ApiResponse.success(updatedClub, "Update Club successfully"));
        } catch (Exception e) {
            if (e.getMessage().contains("ContactPhoneAlreadyExists")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Contact phone already exists"));
            }
            if (e.getMessage().contains("ClubNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @DeleteMapping("/club/delete/{id}")
    public ResponseEntity<?> deleteClub(@PathVariable int id) {
        try {
            clubService.deleteClubById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(id, "Delete Club successfully"));
        } catch (Exception e) {
            if (e.getMessage().contains("ClubNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= CLUB IMAGE ============================
    @PostMapping("/clubImage/add")
    public ResponseEntity<?> saveClubImage(@Valid @ModelAttribute ClubImageDTO clubImageDTO, BindingResult bindingResult) {
        try {
            Club clubExisting = clubService.getClubById(clubImageDTO.getClubId());
            if (clubExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club not found"));
            }
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            if (clubImageDTO.getFile() == null) {
                bindingResult.rejectValue("image", "400");
                return ResponseEntity.badRequest().body(bindingResult);
            }
            ClubImages createClubImage = clubService.addClubImages(clubImageDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(createClubImage, "Create Club Image successfully"));
        } catch (Exception e) {
            if (e.getMessage().contains("PrimaryImageAlreadyExists")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("PrimaryImage already exists"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/clubImage/update/{id}")
    public ResponseEntity<?> updateImageClub(@PathVariable int id,
                                             @Valid @ModelAttribute ClubImageDTO clubImageDTO,
                                             BindingResult bindingResult) {
        try {
            Optional<ClubImages> clubImageExisting = clubService.findClubImageById(id);
            if (clubImageExisting.isEmpty()) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            ClubImages updatedHotelImages = clubService.updateClubImage(id, clubImageDTO);
            return ResponseEntity.status(HttpStatus.OK).body(ApiResponse
                    .success(updatedHotelImages, "update club images successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("PrimaryImageAlreadyExists")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("PrimaryImage already exists"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @DeleteMapping("/clubImage/delete/{id}")
    public ResponseEntity<?> deleteImageClub(@PathVariable int id) {
        try {
            Optional<ClubImages> clubImageExisting = clubService.findClubImageById(id);
            if (clubImageExisting.isEmpty()) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            ClubImages deletedClubImage = clubService.deleteClubImageById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(deletedClubImage, "Delete Club Image successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }

    @PutMapping("/clubImage/primary/{id}")
    public ResponseEntity<?> updateImagePrimaryClub(@PathVariable int id) {
        try {
            Optional<ClubImages> clubImageExisting = clubService.findClubImageById(id);
            if (clubImageExisting.isEmpty()) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            clubService.activePrimaryClubImageById(id, clubImageExisting.get().getClub().getId());
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Update Primary Club Image successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + ex.getMessage()));
        }
    }

    //======================= BRANCH ============================
    @PostMapping("/branch/add")
    public ResponseEntity<?> addBranch(@Valid @RequestBody BranchDTO branchDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Branch newBranch = branchService.createBranch(branchDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newBranch, "Add Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/branch/update/{id}")
    public ResponseEntity<?> updateBranch(@PathVariable int id, @Valid @RequestBody BranchDTO branchDTO, BindingResult bindingResult) {
        try {
            Branch branchExisting = branchService.getBranchById(id);
            if (branchExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Branch updateBranch = branchService.updateBranch(id, branchDTO);
            return ResponseEntity.status(201).body(ApiResponse.success(updateBranch, "Update Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }

    @DeleteMapping("/branch/delete/{id}")
    public ResponseEntity<?> deleteBranch(@PathVariable int id) {
        try {
            Branch branchExisting = branchService.getBranchById(id);
            if (branchExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            branchService.deleteBranch(id);
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Delete Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }

    //======================= TRAINER ============================
    @PostMapping("/trainer/add")
    public ResponseEntity<?> addTrainer(@Valid @ModelAttribute TrainerDTO trainerDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Branch branchExisting = branchService.getBranchById(trainerDTO.getBranch());
            if (branchExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            Trainer newTrainer = trainerService.createTrainer(trainerDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newTrainer, "Add Trainer successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/trainer/update/{id}")
    public ResponseEntity<?> updateTrainer(@PathVariable int id, @Valid @ModelAttribute TrainerDTO trainerDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Trainer trainerExisting = trainerService.getTrainerById(id);
            if (trainerExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Trainer not found"));
            }
            Branch branchExisting = branchService.getBranchById(trainerDTO.getBranch());
            if (branchExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            Trainer trainerUpdate = trainerService.updateTrainer(id,trainerDTO);
            return ResponseEntity.status(200).body(ApiResponse.success(trainerUpdate, "Update Trainer successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("error server" + e.getMessage()));
        }
    }


    @DeleteMapping("/trainer/delete/{id}")
    public ResponseEntity<?> deleteTrainer(@PathVariable int id) {
        try {
            Trainer trainerExisting = trainerService.getTrainerById(id);
            if (trainerExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Trainer not found"));
            }
            trainerService.deleteTrainer(id);
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Delete Trainer successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= ROOM ============================
    @PostMapping("/room/add")
    public ResponseEntity<?> addRoom(@Valid @RequestBody RoomDTO roomDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Branch branchExisting = branchService.getBranchById(roomDTO.getBranch());
            if (branchExisting == null) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            Room newRoom = roomService.addRoom(roomDTO);
            return ResponseEntity.status(201).body(ApiResponse.success(newRoom, "Add Room successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @PutMapping("/room/update/{id}")
    public ResponseEntity<?> editRoom(@PathVariable int id, @Valid @RequestBody RoomDTO roomDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Room updateRoom = roomService.updateRoom(id, roomDTO);
            return ResponseEntity.status(201).body(ApiResponse.success(updateRoom, "Update Room successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("RoomNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Room not found"));
            }
            if (e.getMessage().contains("BranchNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Branch not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server " + e.getMessage()));
        }
    }

    @DeleteMapping("/room/delete/{id}")
    public ResponseEntity<?> deleteRoom(@PathVariable int id) {
        try {
            roomService.deleteRoom(id);
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Delete Room successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("RoomNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Room not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

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
