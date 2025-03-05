package data.smartdeals_service.services.promotionServices;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.component.ApplicationProperties;
import data.smartdeals_service.dto.email.MailEntity;
import data.smartdeals_service.dto.promotion.PromotionDTO;
import data.smartdeals_service.dto.promotion.PromotionOfUserDTO;
import data.smartdeals_service.dto.promotion.PromotionPointDTO;
import data.smartdeals_service.dto.promotion.PromotionStatusDTO;
import data.smartdeals_service.dto.user.UserDTO;
import data.smartdeals_service.dto.user.UserPoinDTO;
import data.smartdeals_service.eureka_client.ErurekaService;
import data.smartdeals_service.eureka_client.PointServiceClient;
import data.smartdeals_service.models.promotion.Promotion;
import data.smartdeals_service.models.user.UserPromotion;
import data.smartdeals_service.repository.promotioRepositories.PromotionRepository;
import data.smartdeals_service.repository.userRepository.UserPromotionRepository;
import data.smartdeals_service.services.email.MailResetPass;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.io.File;
import java.io.IOException;

@Service
@RequiredArgsConstructor
public class PromotionService {
    private final PromotionRepository promotionRepository;
    private final MailResetPass mailResetPass;
    private final ErurekaService erurekaService;
    private final UserPromotionRepository userPromotionRepository;
    private final PointServiceClient pointServiceClient;

    private final ApplicationProperties applicationProperties;
    private static final String PROMOTION_FILE_NAME = "promotions.json";
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

    public Promotion findCode(String code) {
        Promotion promotion = promotionRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("InvalidCode" ));
        return promotion;
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
        promotion.setCreatedBy(promotionDTO.getCreatedBy());
        promotion.setCreatedDate(LocalDateTime.now());
        promotion.setPackageName(promotionDTO.getPackageName());
        promotion.setCode(code);
        // Save to database
        promotionRepository.save(promotion);
        return code;
    }

    // save promotion vào file json
    public String savePromotions(PromotionPointDTO promotion) {
        ObjectMapper objectMapper = new ObjectMapper();
        String filePath = applicationProperties.getJsonFolder() + PROMOTION_FILE_NAME;

        ensureJsonFolderExists(applicationProperties.getJsonFolder());

        try {
            // Bước 1: Đọc danh sách hiện có từ file JSON (nếu file tồn tại)
            List<PromotionPointDTO> promotions = new ArrayList<>();
            File file = new File(filePath);
            if (file.exists()) {
                promotions = objectMapper.readValue(file, new TypeReference<List<PromotionPointDTO>>() {});
            }
            // Bước 2: Thêm đối tượng mới vào danh sách
            promotion.setCode(generateUniqueCode());
            promotion.setId(generateUniqueCode());
            promotion.setStartDate(null);
            promotion.setEndDate(null);
            promotions.add(promotion);
            // Bước 3: Ghi danh sách vào file JSON với định dạng đẹp
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(file, promotions);
            return "Promotion saved successfully!";
        } catch (IOException e) {
            e.printStackTrace();
            return "Error while saving promotion to file.";
        }
    }

    private void ensureJsonFolderExists(String folderPath) {
        // create object navigate in folderpath
        File folder = new File(folderPath);
        if (!folder.exists()) { //if isn't
            folder.mkdirs(); // create new
        }
    }

    public void deletePromotion(Long id) {
        promotionRepository.deleteById(id);
    }

    public Promotion closePromotionStatus(Long id,PromotionStatusDTO status) {
        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Promotion not found with id: " + id));
        promotion.setUpdatedAt(LocalDateTime.now());
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
        List<UserPromotion> userPromotions = userPromotionRepository.findByUserIdAndPromotionCode(userId, promotionCode);
        Promotion promotion = promotionRepository.findByCode(promotionCode)
                .orElseThrow(() -> new RuntimeException("PromotionCodeIsInvalid"));

        LocalDateTime startDate = promotion.getStartDate();
        LocalDateTime endDate = promotion.getEndDate();

        UserPromotion userPromotion = new UserPromotion();
        if (!userPromotions.isEmpty()) {
            userPromotion = userPromotions.get(0);

            if (!userPromotion.getIsUsed()) {
                userPromotion.setIsUsed(true);
            }
            userPromotion.setPromotionAmount(userPromotion.getPromotionAmount() + 1);

        }else {
            userPromotion.setPromotionAmount(1L);
        }
        userPromotion.setUserId(userId);
        userPromotion.setPromotionCode(promotionCode);
        userPromotion.setIsUsed(true);
        userPromotion.setStartDate(startDate);
        userPromotion.setEndDate(endDate);
        userPromotionRepository.save(userPromotion);
    }
    public void sendCodeToUser(String code, String email) {
        email = email.trim();
        UserDTO user = erurekaService.getUserByEmail(email);
        if (user == null) {
            System.out.println("userrr được lấy" + user);
            throw new IllegalArgumentException("User not found");
        }
        try {
            sendPromotionEmail(user.getEmail(), code);
            saveUserPromotion(user.getId(), code);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("FailedToSendEmailToUserWithID");
        }
    }

    public List<UserPromotion> getUserPromotions() {
        return userPromotionRepository.findAll();
    }
    public  List<UserPromotion> getUserPromotionByUserId(Long userId) {
        UserDTO user = erurekaService.getUserById(userId);
        if(user == null) {
            throw new RuntimeException("UserNotFoundException");
        }
        return userPromotionRepository.findByUserId(userId);
    }
    public PromotionOfUserDTO findPromotionCode(String code,Long userId) {
        UserPromotion entity = userPromotionRepository.findUserPromotionByPromotionCodeAndUserId(code,userId)
                .orElseThrow(() -> new RuntimeException("InvalidCode" ));
        Promotion promotion = promotionRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("InvalidCode" ));

        PromotionOfUserDTO promotionDTO = new PromotionOfUserDTO();
        promotionDTO.setId(promotion.getId());
        promotionDTO.setUserId(userId);
        promotionDTO.setTitle(promotion.getTitle());
        promotionDTO.setDescription(promotion.getDescription());
        promotionDTO.setDiscountValue(promotion.getDiscountValue());
        promotionDTO.setDiscountType(promotion.getDiscountType());
        promotionDTO.setApplicableService(promotion.getApplicableService());
        promotionDTO.setMinValue(promotion.getMinValue());
        promotionDTO.setCode(entity.getPromotionCode());
        promotionDTO.setPromotionAmount(entity.getPromotionAmount());
        promotionDTO.setStartDate(promotion.getStartDate());
        promotionDTO.setEndDate(promotion.getEndDate());
        promotionDTO.setIsUsed(entity.getIsUsed());
        return promotionDTO;
    }

    @Transactional
    public String UsedPromotionCode(Long userId, String promotionCode) {
        UserPromotion entity = userPromotionRepository.findUserPromotionByPromotionCodeAndUserId(promotionCode,userId)
                .orElseThrow(() -> new RuntimeException("InvalidCode" ));
        if(entity == null) {
            throw new RuntimeException("UserNotFoundException");
        }
        else {
            if (!entity.getIsUsed()) {
                throw new RuntimeException("CodeIsAlreadyInActive");
            }
            else {
                if (entity.getPromotionAmount() == 0) {
                    entity.setIsUsed(false);
                    userPromotionRepository.save(entity);
                    return "Promotion code " + promotionCode + " has been deactivated.";
                } else if (entity.getPromotionAmount() == 1) {
                    entity.setPromotionAmount(entity.getPromotionAmount() - 1);
                    entity.setIsUsed(false);
                    userPromotionRepository.save(entity);
                    return "Promotion code " + promotionCode + " has been used. Remaining amount: " + entity.getPromotionAmount();
                } else {
                    entity.setPromotionAmount(entity.getPromotionAmount() - 1);
                    userPromotionRepository.save(entity);
                    return "Promotion code " + promotionCode + " has been used. Remaining amount: " + entity.getPromotionAmount();
                }
            }

        }

    }

    public List<PromotionOfUserDTO> getPromotionUser(Long userId) {
        UserDTO user = erurekaService.getUserById(userId);
        if (user == null) {
            throw new RuntimeException("UserNotFoundException");
        }
        List<UserPromotion> userPromotions = userPromotionRepository.findByUserId(userId);
        if (userPromotions == null || userPromotions.isEmpty()) {
            return Collections.emptyList();
        }
        List<PromotionOfUserDTO> promotionOfUserDTOs = new ArrayList<>();
        for (UserPromotion userPromotion : userPromotions) {
            if (!userPromotion.getUserId().equals(userId)) {
                continue;
            }
            Promotion promotion = promotionRepository.findPromotionByCode(userPromotion.getPromotionCode());
            if (promotion == null) {
                continue;
            }
            PromotionOfUserDTO promotionDTO = new PromotionOfUserDTO();
            promotionDTO.setId(promotion.getId());
            promotionDTO.setUserId(userId);
            promotionDTO.setTitle(promotion.getTitle());
            promotionDTO.setDescription(promotion.getDescription());
            promotionDTO.setDiscountValue(promotion.getDiscountValue());
            promotionDTO.setDiscountType(promotion.getDiscountType());
            promotionDTO.setApplicableService(promotion.getApplicableService());
            promotionDTO.setMinValue(promotion.getMinValue());
            promotionDTO.setCode(promotion.getCode());
            promotionDTO.setPromotionAmount(userPromotion.getPromotionAmount());
            promotionDTO.setStartDate(promotion.getStartDate());
            promotionDTO.setEndDate(promotion.getEndDate());
            promotionDTO.setIsUsed(userPromotion.getIsUsed());
            promotionDTO.setCustomerType(promotion.getCustomerType());
            promotionDTO.setPackageName(promotion.getPackageName());
            promotionDTO.setCreatedBy(promotion.getCreatedBy());
            promotionOfUserDTOs.add(promotionDTO);
        }
        return promotionOfUserDTOs;
    }


    // method create promotion and subtract point
    @Transactional
    public boolean redeemDiscountCode (Long userId, int point, String promotionId) {
        PromotionPointDTO getOnePromotion = getPromotionByIdInJson(promotionId);
        if(getOnePromotion != null) {
            int totalPoint = getOnePromotion.getPoints();
            switch (point){
                case 500:
                case 1000:
                case 1500:
                case 2000:
                case 2500:
                case 3000:
                case 3500:
                case 4000:
                case 4500:
                case 5000:
                case 5500:
                case 6000:
                case 6500:
                case 7000:
                case 7500:
                case 8000:
                case 8500:
                case 9000:
                case 9500:
                case 10000:
                    if (totalPoint >= point){
                        // create promotion
                        Promotion promotion = promotionRepository.findPromotionByCode(getOnePromotion.getCode());
                        if(promotion == null) {
                            Promotion newPromotion = new Promotion();
                            newPromotion.setTitle(getOnePromotion.getTitle());
                            newPromotion.setDescription(getOnePromotion.getDescription());
                            newPromotion.setDiscountType(getOnePromotion.getDiscountType());
                            newPromotion.setDiscountValue(getOnePromotion.getDiscountValue());
                            newPromotion.setCustomerType(getOnePromotion.getCustomerType());
                            newPromotion.setApplicableService(getOnePromotion.getApplicableService());
                            newPromotion.setStartDate(LocalDateTime.now());
                            newPromotion.setEndDate(calculateEndDate(LocalDateTime.now()));
                            newPromotion.setIsActive(getOnePromotion.getIsActive());
                            newPromotion.setMinValue(getOnePromotion.getMinValue());
                            newPromotion.setCreatedBy(getOnePromotion.getCreatedBy());
                            newPromotion.setCreatedDate(LocalDateTime.now());
                            newPromotion.setPackageName(getOnePromotion.getPackageName());
                            newPromotion.setCode(getOnePromotion.getCode());
                            promotionRepository.save(newPromotion);
                        }
                        // create promotionUser
                        saveUserPromotion(userId,getOnePromotion.getCode());
                        // subtract point
                        pointServiceClient.approvePoint(userId, point);
                    }else {
                        throw new RuntimeException("NotEnoughPointsToDeduct");
                    }
                    break;
                default:
                    throw new RuntimeException("InvalidPointId");
            }
        }else {
            return false;
        }
        return true;
    }
    private LocalDateTime calculateEndDate(LocalDateTime startDate) {
        Duration duration = Duration.ofHours(5);
        return startDate.plus(duration);
    }

    // get one promotion by id in json
    public PromotionPointDTO getPromotionByIdInJson(String id) {
        ObjectMapper objectMapper = new ObjectMapper();
        String filePath = applicationProperties.getJsonFolder() + PROMOTION_FILE_NAME;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                throw new FileNotFoundException("JSON file not found at path: " + filePath);
            }
            List<PromotionPointDTO> promotions = objectMapper.readValue(file, new TypeReference<List<PromotionPointDTO>>() {});
            for (PromotionPointDTO promotion : promotions) {
                if (promotion.getId().equals(id)) {
                    return promotion;
                }
            }
            return null;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
    // get all promotion in json
    public List<PromotionPointDTO> getAllPromotionsInJson() {
        ObjectMapper objectMapper = new ObjectMapper();
        String filePath = applicationProperties.getJsonFolder() + PROMOTION_FILE_NAME;
        try {
            File file = new File(filePath);
            if (!file.exists()) {
                throw new FileNotFoundException("JSON file not found at path: " + filePath);
            }
            // Đọc toàn bộ dữ liệu trong file JSON vào danh sách các đối tượng PromotionPointDTO
            List<PromotionPointDTO> promotions = objectMapper.readValue(file, new TypeReference<List<PromotionPointDTO>>() {});
            return promotions;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}