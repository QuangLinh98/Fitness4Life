package data.smartdeals_service.controller.promotion;

import data.smartdeals_service.dto.promotion.PromotionDTO;
import data.smartdeals_service.dto.promotion.PromotionPointDTO;
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
@RestController
@RequestMapping("/api/deal/promotions")
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

    @PostMapping("/saveJson")
    public ResponseEntity<String> savePromotion(@RequestBody PromotionPointDTO promotion) {  // Nhận 1 đối tượng PromotionDTO
        String result = promotionService.savePromotions(promotion);  // Gửi đối tượng đến service

        if (result.equals("Promotion saved successfully!")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.status(500).body(result);
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
    @GetMapping("/{code}")
    public ResponseEntity<?> findCode(@PathVariable String code) {
        try {
            Promotion result = promotionService.findCode(code);
            return ResponseEntity.ok(ApiResponse.success(result, "get code successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("InvalidCode")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("code not found"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @GetMapping("/json/{id}")
    public ResponseEntity<?> findPromotionInJson(@PathVariable String id) {
        try {
            PromotionPointDTO result = promotionService.getPromotionByIdInJson(id);
            return ResponseEntity.ok(ApiResponse.success(result, "get code successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }
    @GetMapping("/json/all")
    public ResponseEntity<?> getAllPromotionsInJson() {
        try {
            List<PromotionPointDTO> result = promotionService.getAllPromotionsInJson();
            return ResponseEntity.ok(ApiResponse.success(result, "get code successfully"));
        } catch (Exception ex) {
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
    public ResponseEntity<?> sendCodeToAllUsers(@RequestParam String code) {
        try {
            promotionService.sendCodeToAllUsers(code);
            return ResponseEntity.ok("Code has been sent to all users.");

        }catch (RuntimeException ex) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

    @PostMapping("/send-code-to-user")
    public ResponseEntity<?> sendCodeToUser(@RequestParam String code, @RequestParam String email) {
        try {
            promotionService.sendCodeToUser(code, email);
            return ResponseEntity.ok("Code has been sent to user with ID: " + email);
        }catch (Exception ex) {
            if (ex.getMessage().contains("CodeIsAlreadyInSend")) {
                return ResponseEntity.status(401).body(ApiResponse.badRequest("Code Is Already In Send"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }

}