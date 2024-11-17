package fpt.aptech.dashboardservice.controller;

import fpt.aptech.dashboardservice.dtos.ClubPrimaryImageDTO;
import fpt.aptech.dashboardservice.helpers.ApiResponse;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.service.ClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/public")
@RequiredArgsConstructor
public class PublicController {
    private final ClubService clubService;

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

}
