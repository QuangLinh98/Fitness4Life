package data.smartdeals_service.repository.promotioRepositories;

import data.smartdeals_service.models.promotion.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PromotionRepository extends JpaRepository<Promotion, Long> {
    @Modifying
    @Query("UPDATE Promotion p SET p.isActive = false, p.updatedAt = CURRENT_TIMESTAMP WHERE p.endDate <= :currentTime AND p.isActive = true")
    void bulkClosePromotions(@Param("currentTime") LocalDateTime currentTime);

    @Modifying
    @Query("DELETE FROM Promotion p WHERE p.isActive = false AND p.updatedAt <= :timeLimit")
    void deleteInactivePromotions(@Param("timeLimit") LocalDateTime timeLimit);

    boolean existsByCode(String code);
    Optional<Promotion> findByCode(String code);

    Promotion findPromotionByCode(String promotionCode);
    List<Promotion> findByIsActiveTrue();
}
