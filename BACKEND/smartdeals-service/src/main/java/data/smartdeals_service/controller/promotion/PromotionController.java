package data.smartdeals_service.controller.promotion;

import data.smartdeals_service.dto.promotion.PromotionDTO;
import data.smartdeals_service.dto.promotion.PromotionStatusDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.promotion.Promotion;
import data.smartdeals_service.services.promotionServices.PromotionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/promotions")
@RequiredArgsConstructor
public class PromotionController {
    private final PromotionService promotionService;

    @GetMapping
    public ResponseEntity<?> getAllPromotions() {
        try {
            List<Promotion> promotions = promotionService.getAllPromotions();
            return ResponseEntity.ok(ApiResponse.success(promotions, "get all promotions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @PostMapping("/create")
    public ResponseEntity<?> createPromotion(@RequestBody PromotionDTO promotionDTO,
                                             BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            String savedPromotion =  promotionService.createPromotion(promotionDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(savedPromotion,"create Promotion successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @DeleteMapping("/{id}")
    public void deletePromotion(@PathVariable Long id) {
        promotionService.deletePromotion(id);
    }

    @PutMapping("/changePublished/{id}")
    public ResponseEntity<?> changePublished(@PathVariable Long id, @RequestBody PromotionStatusDTO promotionStatusDTO,
                                             BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Promotion changePublished = promotionService.closePromotionStatus(id,promotionStatusDTO);
            return  ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(changePublished,"change Published successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verifyCode(@RequestParam String code) {
        try {
            String result = promotionService.verifyCode(code);
            return ResponseEntity.ok(ApiResponse.success(result, "used code successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("InvalidCode")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("code not found"));
            }
            if (ex.getMessage().contains("CodeIsAlreadyInActive")) {
                return ResponseEntity.status(402).body(ApiResponse.badRequest("Code Is Already In active"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/active")
    public ResponseEntity<List<PromotionDTO>> getActivePromotions() {
        List<PromotionDTO> promotions = promotionService.getActivePromotions();
        return ResponseEntity.ok(promotions);
    }

    @PostMapping("/send-code-to-all")
    public ResponseEntity<String> sendCodeToAllUsers(@RequestParam String code) {
        promotionService.sendCodeToAllUsers(code);
        return ResponseEntity.ok("Code has been sent to all users.");
    }

    @PostMapping("/send-code-to-user")
    public ResponseEntity<String> sendCodeToUser(@RequestParam String code, @RequestParam Long userId) {
        promotionService.sendCodeToUser(code, userId);
        return ResponseEntity.ok("Code has been sent to user with ID: " + userId);
    }

}