package fpt.aptech.dashboardservice.controller;

import fpt.aptech.dashboardservice.dtos.ClubPrimaryImageDTO;
import fpt.aptech.dashboardservice.helpers.ApiResponse;
import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.Room;
import fpt.aptech.dashboardservice.models.Trainer;
import fpt.aptech.dashboardservice.service.BranchService;
import fpt.aptech.dashboardservice.service.ClubService;
import fpt.aptech.dashboardservice.service.RoomService;
import fpt.aptech.dashboardservice.service.TrainerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class PublicController {
    private final ClubService clubService;
    private final BranchService branchService;
    private final TrainerService trainerService;
    private final RoomService roomService;

    //======================= CLUB ============================
    @GetMapping("/clubs")
    public ResponseEntity<?> getAllClub() {
        try {
            List<Club> clubs = clubService.getAllClubs();
            return ResponseEntity.status(200).body(ApiResponse.success(clubs, "Get All Clubs successfull"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("/club/{id}")
    public ResponseEntity<?> getClubById(@PathVariable int id) {
        try {
            Club club = clubService.getClubById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(club, "Get Club successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    // API get all Club with primary image
    @GetMapping("/clubImage/image-primary")
    public ResponseEntity<?> getAllClubWithImagePrimary() {
        try {
            List<ClubPrimaryImageDTO> clubs = clubService.getAllClubWithPrimaryImage();
            return ResponseEntity.ok(ApiResponse.success(clubs, "Get All Clubs successfull"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= BRANCH ============================
    @GetMapping("/branchs")
    public ResponseEntity<?> getAllBranch() {
        try {
            List<Branch> branches = branchService.getAllBranch();
            return ResponseEntity.status(200).body(ApiResponse.success(branches, "Get All Branch successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("/branch/{id}")
    public ResponseEntity<?> getBranchById(@PathVariable int id) {
        try {
            Branch branch = branchService.getBranchById(id);
            if (branch == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Branch not found"));
            }
            return ResponseEntity.status(200).body(ApiResponse.success(branch, "Get Branch successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= TRAINER ============================
    @GetMapping("/trainers")
    public ResponseEntity<?> getAllTrainer() {
        try {
            List<Trainer> trainers = trainerService.getAllTrainer();
            return ResponseEntity.status(200).body(ApiResponse.success(trainers, "Get All Trainer successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("/trainer/{id}")
    public ResponseEntity<?> getTrainerById(@PathVariable int id) {
        try {
            Trainer trainer = trainerService.getTrainerById(id);
            if (trainer == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Trainer not found"));
            }
            return ResponseEntity.status(200).body(ApiResponse.success(trainer, "Get Trainer successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    //======================= ROOM ============================
    @GetMapping("/rooms")
    public ResponseEntity<?> getAllRoom() {
        try {
            List<Room> rooms =  roomService.getAllRoom();
            return ResponseEntity.status(200).body(ApiResponse.success(rooms, "Get All Room successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

    @GetMapping("/room/{id}")
    public ResponseEntity<?> getRoomById(@PathVariable int id) {
        try {
            Room room = roomService.getRoomById(id);
            if (room == null) {
                return ResponseEntity.status(404).body(ApiResponse.errorServer("Room not found"));
            }
            return ResponseEntity.status(200).body(ApiResponse.success(room, "Get Room successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server" + e.getMessage()));
        }
    }

}
