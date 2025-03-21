package kj001.user_service.controllers;

import kj001.user_service.dtos.FaceDataReponse;
import kj001.user_service.helpers.ApiResponse;
import kj001.user_service.models.AuthenticationResponse;
import kj001.user_service.service.FaceAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
    @RequestMapping("/api/face-auth")
public class FaceAuthController {

    private final FaceAuthService faceAuthService;

    @Autowired
    public FaceAuthController(FaceAuthService faceAuthService) {
        this.faceAuthService = faceAuthService;
    }

    @PostMapping("/register/{userId}")
    public ResponseEntity<?> registerFace(
            @PathVariable Long userId,
            @RequestParam("file") MultipartFile faceImage) {
        try {
            faceAuthService.registerFace(userId, faceImage);
            return ResponseEntity.ok(ApiResponse.success(true, "Face registered successfully"));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("already registered")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.badRequest("This face is already registered to another user"));
            }
            return ResponseEntity.badRequest()
                    .body(ApiResponse.badRequest("Failed to register face: " + e.getMessage()));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginWithFace(@RequestParam("file") MultipartFile faceImage) {
        try {
            AuthenticationResponse response = faceAuthService.loginWithFace(faceImage);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.badRequest("Face login failed: " + e.getMessage()));
        }
    }
    @GetMapping
    public ResponseEntity<?> getAllFaceData() {
        try {
            List<FaceDataReponse> allFaceData = faceAuthService.getAllFaceData();
            return ResponseEntity.ok(ApiResponse.success(allFaceData, "All face data retrieved successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.badRequest("Failed to retrieve face data: " + e.getMessage()));
        }
    }
    @PutMapping("/update/{userId}")
    public ResponseEntity<?> updateFace(
            @PathVariable Long userId,
            @RequestParam("file") MultipartFile faceImage) {
        try {
            faceAuthService.updateFace(userId, faceImage);
            return ResponseEntity.ok(ApiResponse.success(true, "Face updated successfully"));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("already registered")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.badRequest("This face is already registered to another user"));
            }
            return ResponseEntity.badRequest()
                    .body(ApiResponse.badRequest("Failed to update face: " + e.getMessage()));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}