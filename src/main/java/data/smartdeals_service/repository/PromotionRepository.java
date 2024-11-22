package data.smartdeals_service.repository;

import data.smartdeals_service.models.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PromotionRepository extends JpaRepository<Promotion, Long> {
    List<Promotion> findByEndDateBeforeAndIsActive(LocalDateTime endDate, boolean isActive);
}
