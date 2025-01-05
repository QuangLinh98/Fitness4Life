package data.smartdeals_service.services.promotionServices;

import data.smartdeals_service.dto.email.MailEntity;
import data.smartdeals_service.dto.promotion.PromotionDTO;
import data.smartdeals_service.dto.promotion.PromotionStatusDTO;
import data.smartdeals_service.dto.user.UserDTO;
import data.smartdeals_service.eureka_client.ErurekaService;
import data.smartdeals_service.models.promotion.Promotion;
import data.smartdeals_service.models.user.UserPromotion;
import data.smartdeals_service.repository.promotioRepositories.PromotionRepository;
import data.smartdeals_service.repository.userRepository.UserPromotionRepository;
import data.smartdeals_service.services.email.MailResetPass;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.UnsupportedEncodingException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PromotionService {
    private final PromotionRepository promotionRepository;
    private final MailResetPass mailResetPass;
    private final ErurekaService erurekaService;
    private final UserPromotionRepository userPromotionRepository;
    public List<Promotion> getAllPromotions() {
        return promotionRepository.findAll();
    }

    @Transactional
    public String verifyCode(String code) {
        // Tìm promotion bằng code
        Promotion promotion = promotionRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("InvalidCode" ));

        // Kiểm tra trạng thái của isActive
        if (promotion.getIsActive()) {
            promotion.setIsActive(false); // Đổi trạng thái sang false
            promotionRepository.save(promotion); // Lưu thay đổi
            return "Code " + code + " has been successfully deactivated.";
        } else {
            throw new RuntimeException("CodeIsAlreadyInActive");
        }
    }
    public String createPromotion(PromotionDTO promotionDTO) {
        String code = generateUniqueCode();
        Promotion promotion = new Promotion();
        promotion.setTitle(promotionDTO.getTitle());
        promotion.setDescription(promotionDTO.getDescription());
        promotion.setDiscountType(promotionDTO.getDiscountType());
        promotion.setDiscountValue(promotionDTO.getDiscountValue());
        promotion.setCustomerType(promotionDTO.getCustomerType());
        promotion.setApplicableService(promotionDTO.getApplicableService());
        promotion.setStartDate(promotionDTO.getStartDate());
        promotion.setEndDate(promotionDTO.getEndDate());
        promotion.setIsActive(promotionDTO.getIsActive());
        promotion.setMinValue(promotionDTO.getMinValue());
        promotion.setMaxUsage(promotionDTO.getMaxUsage());
        promotion.setCreatedBy(promotionDTO.getCreatedBy());
        promotion.setCreatedDate(LocalDateTime.now());
        promotion.setPackageName(promotionDTO.getPackageName());
        promotion.setCode(code);
        // Save to database
        promotionRepository.save(promotion);
        return code;
    }

    public void deletePromotion(Long id) {
        promotionRepository.deleteById(id);
    }

    public Promotion closePromotionStatus(Long id,PromotionStatusDTO status) {
        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Promotion not found with id: " + id));
        promotion.setIsActive(status.getIsActive());
        return promotionRepository.save(promotion);
    }
    private String generateUniqueCode() {
        String code;
        do {
            code = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        } while (promotionRepository.existsByCode(code));
        return code;
    }
    public List<PromotionDTO> getActivePromotions() {
        return promotionRepository.findByIsActiveTrue()
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private PromotionDTO mapToDTO(Promotion promotion) {
        PromotionDTO dto = new PromotionDTO();
        dto.setTitle(promotion.getTitle());
        dto.setDescription(promotion.getDescription());
        dto.setDiscountType(promotion.getDiscountType());
        dto.setDiscountValue(promotion.getDiscountValue());
        dto.setStartDate(promotion.getStartDate());
        dto.setEndDate(promotion.getEndDate());
        dto.setIsActive(promotion.getIsActive());
        dto.setApplicableService(promotion.getApplicableService());
        dto.setMinValue(promotion.getMinValue());
        dto.setCustomerType(promotion.getCustomerType());
        dto.setMaxUsage(promotion.getMaxUsage());
        dto.setCreatedBy(promotion.getCreatedBy());
        dto.setPackageName(promotion.getPackageName());
        dto.setCode(promotion.getCode());
        return dto;
    }
    private void sendPromotionEmail(String email, String code) throws MessagingException, UnsupportedEncodingException {
        MailEntity mail = new MailEntity();
        mail.setEmail(email);
        mail.setSubject("Your Promotion Code");
        mail.setContent("Here is your promotion code: " + code);
        mailResetPass.sendMailOTP(mail);
    }

    public void sendCodeToAllUsers(String code) {
        List<UserDTO> users = erurekaService.getAllUser();

        users.forEach(user -> {
            // Gửi email
            try {
                sendPromotionEmail(user.getEmail(), code);
                // Tự động thêm thông tin vào bảng UserPromotion
                saveUserPromotion(user.getId(), code);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
    private void saveUserPromotion(Long userId, String promotionCode) {
        // Kiểm tra nếu bản ghi đã tồn tại
        if (userPromotionRepository.findByUserIdAndPromotionCode(userId, promotionCode).isPresent()) {
            return; // Nếu đã tồn tại, không làm gì
        }
        // Thêm mới UserPromotion
        UserPromotion userPromotion = new UserPromotion();
        userPromotion.setUserId(userId);
        userPromotion.setPromotionCode(promotionCode);
        userPromotion.setIsUsed(false);
        userPromotionRepository.save(userPromotion);
    }
    public void sendCodeToUser(String code, Long userId) {
        UserDTO user = erurekaService.getUserById(userId);

        try {
            // Gửi email
            sendPromotionEmail(user.getEmail(), code);

            // Tự động thêm thông tin vào bảng UserPromotion
            saveUserPromotion(userId, code);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to send email to user with ID: " + userId);
        }
    }

}