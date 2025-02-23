package fpt.aptech.dashboardservice.controller;

import fpt.aptech.dashboardservice.dtos.ClubPrimaryImageDTO;
import fpt.aptech.dashboardservice.helpers.ApiResponse;
import fpt.aptech.dashboardservice.models.*;
import fpt.aptech.dashboardservice.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
//import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard/")

@RequiredArgsConstructor
public class PublicController {
    private final ClubService clubService;
    private final BranchService branchService;
    private final TrainerService trainerService;
    private final RoomService roomService;
    private final WorkoutPackageClassService packageClassService;


    //======================= CLUB ============================
    @GetMapping("clubs")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getAllClub() {
        try {
            List<Club> clubs = clubService.getAllClubs();
            return ResponseEntity.status(200).body(ApiResponse.success(clubs, "Get All Clubs successfull"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("club/{id}")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getClubById(@PathVariable int id) {
        try {
            Club club = clubService.getClubById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(club, "Get Club successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    // API get all Club with primary image
    @GetMapping("clubImage/image-primary")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getAllClubWithImagePrimary() {
        try {
            List<ClubPrimaryImageDTO> clubs = clubService.getAllClubWithPrimaryImage();
            return ResponseEntity.ok(ApiResponse.success(clubs, "Get All Clubs successfull"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= BRANCH ============================
    @GetMapping("branchs")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getAllBranch() {
        try {
            List<Branch> branches = branchService.getAllBranch();
            return ResponseEntity.status(200).body(ApiResponse.success(branches, "Get All Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("branch/{id}")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getBranchById(@PathVariable int id) {
        try {
            Branch branch = branchService.getBranchById(id);
            if (branch == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Branch not found"));
            }
            return ResponseEntity.status(200).body(ApiResponse.success(branch, "Get Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= TRAINER ============================
    @GetMapping("trainers")
    //@PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> getAllTrainer() {
        try {
            List<Trainer> trainers = trainerService.getAllTrainer();
            return ResponseEntity.status(200).body(ApiResponse.success(trainers, "Get All Trainer successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("trainer/{id}")
    //@PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> getTrainerById(@PathVariable int id) {
        try {
            Trainer trainer = trainerService.getTrainerById(id);
            if (trainer == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Trainer not found"));
            }
            return ResponseEntity.status(200).body(ApiResponse.success(trainer, "Get Trainer successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= ROOM ============================
    @GetMapping("rooms")
   // //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getAllRoom() {
        try {
            List<Room> rooms = roomService.getAllRoom();
            return ResponseEntity.status(200).body(ApiResponse.success(rooms, "Get All Room successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("room/{id}")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getRoomById(@PathVariable int id) {
        try {
            Room room = roomService.getRoomById(id);
            if (room == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Room not found"));
            }
            return ResponseEntity.ok(room);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= WORKOUT PACKAGE ROOM ============================
    @GetMapping("packages/{packageId}/rooms")
    //@PreAuthorize("hasAnyAuthority('MANAGER','ADMIN')")
    public ResponseEntity<?> getClassesByWorkoutPackage(@PathVariable int packageId,@RequestHeader("Authorization") String token) {
        List<Room> rooms = packageClassService.getRoomsByWorkoutPackage(packageId,token);
        return ResponseEntity.ok(rooms);
    }

}
