package data.smartdeals_service.repository.userRepository;

import data.smartdeals_service.models.user.UserPromotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserPromotionRepository  extends JpaRepository<UserPromotion, Long> {
    List<UserPromotion>  findByUserIdAndPromotionCode(Long userId, String promotionCode);

    List<UserPromotion> findByUserId(Long userId);

    Optional<UserPromotion> findUserPromotionByPromotionCodeAndUserId(String promotionCode,Long userId);
    @Modifying
    @Query("UPDATE UserPromotion u SET u.isUsed = false WHERE u.promotionCode IN " +
            "(SELECT p.code FROM Promotion p WHERE p.isActive = false)")
    void updateUserPromotions(@Param("currentTime") LocalDateTime currentTime);

    @Modifying
    @Query("DELETE FROM UserPromotion u WHERE u.promotionCode NOT IN (SELECT p.code FROM Promotion p)")
    void deleteUserPromotionsWithInvalidCodes();



}
