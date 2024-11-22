package data.smartdeals_service.component;

import data.smartdeals_service.models.Promotion;
import data.smartdeals_service.repository.PromotionRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class PromotionScheduler {

    private final PromotionRepository promotionRepository;

    public PromotionScheduler(PromotionRepository promotionRepository) {
        this.promotionRepository = promotionRepository;
    }

    // Lập lịch kiểm tra mã giảm giá mỗi giờ
//    @Scheduled(fixedRate = 120000) // 1 giờ (đơn vị: ms)
    @Scheduled(cron = "0 0 0 * * ?") // Chạy vào lúc 12h đêm mỗi ngày
    public void closeExpiredPromotions() {
        List<Promotion> expiredPromotions =
                promotionRepository.findByEndDateBeforeAndIsActive(LocalDateTime.now(), true);

        for (Promotion promotion : expiredPromotions) {
            promotion.setIsActive(false); // Đặt trạng thái thành không hoạt động
        }

        promotionRepository.saveAll(expiredPromotions); // Lưu thay đổi vào cơ sở dữ liệu
        System.out.println("Expired promotions have been deactivated.");
    }
}
