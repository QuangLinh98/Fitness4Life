package data.smartdeals_service.component;
import data.smartdeals_service.repository.promotioRepositories.PromotionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PromotionScheduler {

    private final PromotionRepository promotionRepository;

    @Scheduled(cron = "0 * * * * ?")
    @Transactional
    public void checkAndClosePromotions() {
        promotionRepository.bulkClosePromotions(LocalDateTime.now());
    }
}
