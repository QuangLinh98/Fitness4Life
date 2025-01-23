package data.smartdeals_service.component;
import data.smartdeals_service.repository.promotioRepositories.PromotionRepository;
import data.smartdeals_service.repository.userRepository.UserPromotionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PromotionScheduler {

    private final PromotionRepository promotionRepository;
    private final UserPromotionRepository userPromotionRepository;

    @Scheduled(cron = "0 * * * * ?")
    @Transactional
    public void checkAndClosePromotions() {

        LocalDateTime currentTime = LocalDateTime.now();

        promotionRepository.bulkClosePromotions(LocalDateTime.now());

        // Xóa các khuyến mãi isActive = false trong vòng 24 giờ
        LocalDateTime timeLimit = currentTime.minusMinutes(1);
        promotionRepository.deleteInactivePromotions(timeLimit);

        // Cập nhật lại trạng thái isUsed của UserPromotion
        userPromotionRepository.updateUserPromotions(LocalDateTime.now());

        // Xóa các UserPromotion có promotionCode không tồn tại trong bảng Promotion
        userPromotionRepository.deleteUserPromotionsWithInvalidCodes();
    }
}
