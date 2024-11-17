package fpt.aptech.dashboardservice.controller;

import fpt.aptech.dashboardservice.dtos.ClubDTO;
import fpt.aptech.dashboardservice.dtos.ClubImageDTO;
import fpt.aptech.dashboardservice.helpers.ApiResponse;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.ClubImages;
import fpt.aptech.dashboardservice.service.ClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/manager")
@RequiredArgsConstructor
public class ManagerController {
    private final ClubService clubService;

    @PostMapping("/club/add")
    public ResponseEntity<?> saveClub(@Valid @RequestBody ClubDTO clubDTO,BindingResult bindingResult) {
       try {
           if (bindingResult.hasErrors()) {
               return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
           }
           Club newClub = clubService.addClub(clubDTO);
           return ResponseEntity.status(201).body(ApiResponse.created(newClub,"Create a new Club successfully"));
       }
       catch (Exception e) {
           if (e.getMessage().contains("ContactPhoneAlreadyExists")){
               return ResponseEntity.status(400).body(ApiResponse.badRequest("Contact phone already exists"));
           }
           return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server"+ e.getMessage()));
       }
    }

    @PutMapping("/club/update/{id}")
    public ResponseEntity<?>updateClub(@PathVariable int id, @Valid @RequestBody ClubDTO clubDTO,BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Club updatedClub = clubService.updateClub(id, clubDTO);
            return ResponseEntity.status(200).body(ApiResponse.success(updatedClub,"Update Club successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("ContactPhoneAlreadyExists")){
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Contact phone already exists"));
            }
            if (e.getMessage().contains("ClubNotFound")){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server"+ e.getMessage()));
        }
    }

    @DeleteMapping("/club/delete/{id}")
    public ResponseEntity<?> deleteClub(@PathVariable int id) {
        try {
             clubService.deleteClubById(id);
             return ResponseEntity.status(200).body(ApiResponse.success(id,"Delete Club successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("ClubNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club not found"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server"+ e.getMessage()));
        }
    }

    @PostMapping("/clubImage/add")
    public ResponseEntity<?>saveClubImage(@Valid @ModelAttribute ClubImageDTO clubImageDTO, BindingResult bindingResult) {
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
           return ResponseEntity.status(201).body(ApiResponse.created(createClubImage,"Create Club Image successfully"));
        }
        catch (Exception e) {
            if (e.getMessage().contains("PrimaryImageAlreadyExists")){
                return ResponseEntity.status(400).body(ApiResponse.badRequest("PrimaryImage already exists"));
            }
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server"+ e.getMessage()));
        }
    }

    @PutMapping("/clubImage/update/{id}")
    public ResponseEntity<?> updateImageClub(@PathVariable int id,
                                              @Valid @ModelAttribute ClubImageDTO clubImageDTO,
                                              BindingResult bindingResult) {
        try {
            Optional<ClubImages> clubImageExisting = clubService.findClubImageById(id);
            if (clubImageExisting.isEmpty()){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            ClubImages updatedHotelImages = clubService.updateClubImage(id,clubImageDTO);
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
            if (clubImageExisting.isEmpty()){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            ClubImages deletedClubImage = clubService.deleteClubImageById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(deletedClubImage,"Delete Club Image successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(ApiResponse.errorServer("error server"+ e.getMessage()));
        }
    }

    @PutMapping("/clubImage/primary/{id}")
    public ResponseEntity<?>updateImagePrimaryClub(@PathVariable int id) {
        try {
            Optional<ClubImages> clubImageExisting = clubService.findClubImageById(id);
            if (clubImageExisting.isEmpty()){
                return ResponseEntity.status(404).body(ApiResponse.notfound("Club image not found"));
            }
            clubService.activePrimaryClubImageById(id, clubImageExisting.get().getClub().getId());
            return ResponseEntity.status(200).body(ApiResponse.success(null, "Update Primary Club Image successfully"));
        }catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server" + ex.getMessage()));
        }
    }
}
