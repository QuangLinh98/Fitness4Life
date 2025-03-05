package data.smartdeals_service.controller.promotion;

import data.smartdeals_service.dto.promotion.PromotionOfUserDTO;
import data.smartdeals_service.helpers.ApiResponse;
import data.smartdeals_service.models.user.UserPromotion;
import data.smartdeals_service.services.promotionServices.PromotionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/deal/promotionOfUser")
@RequiredArgsConstructor
public class PromotionOfUser {
    private final PromotionService promotionService;

    @GetMapping
    public ResponseEntity<?> getAll() {
        try {
            List<UserPromotion> promotions = promotionService.getUserPromotions();
            return ResponseEntity.ok(ApiResponse.success(promotions, "get all promotions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }
    @GetMapping("/{userId}")
    public ResponseEntity<?> getUserPromotionByUserId(@PathVariable Long userId) {
        try {
            List<UserPromotion> promotions = promotionService.getUserPromotionByUserId(userId);
            return ResponseEntity.ok(ApiResponse.success(promotions, "get all promotions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @GetMapping("/getPromotionUser/{userId}")
    public ResponseEntity<?> getPromotionUser(@PathVariable Long userId) {
        try {
            List<PromotionOfUserDTO> promotions = promotionService.getPromotionUser(userId);
            return ResponseEntity.ok(ApiResponse.success(promotions, "get all promotions successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server"));
        }
    }

    @GetMapping("/{promotionCode}/{userId}")
    public ResponseEntity<?> findCode(@PathVariable String promotionCode,@PathVariable Long userId) {
        try {
            PromotionOfUserDTO result = promotionService.findPromotionCode(promotionCode,userId);
            return ResponseEntity.ok(ApiResponse.success(result, "get code successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("InvalidCode")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("code not found"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }
    @PostMapping("/usedCode/{userId}")
    public ResponseEntity<?> UsedPromotionCode(@PathVariable Long userId,@RequestParam String promotionCode) {
        try {
            String result = promotionService.UsedPromotionCode(userId,promotionCode);
            return ResponseEntity.ok(ApiResponse.success(result, "used code successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("UserNotFoundException")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("User Not Found Exception"));
            }
            if (ex.getMessage().contains("CodeIsAlreadyInActive")) {
                return ResponseEntity.status(401).body(ApiResponse.badRequest("Code Is Already In Active"));
            }
            if (ex.getMessage().contains("PromotionCodeNotFound")) {
                return ResponseEntity.status(402).body(ApiResponse.badRequest("Promotion Code Not Found"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PostMapping("/usedPointChangCode/{userId}")
    public ResponseEntity<?> usedPointChangCode(@PathVariable Long userId, @RequestParam int point, @RequestParam String promotionId) {
        try {
            boolean result = promotionService.redeemDiscountCode(userId,point,promotionId);
            return ResponseEntity.ok(ApiResponse.success(result, "used code successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

}
