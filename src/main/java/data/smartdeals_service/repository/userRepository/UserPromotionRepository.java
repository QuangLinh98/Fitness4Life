package data.smartdeals_service.repository.userRepository;

import data.smartdeals_service.models.user.UserPromotion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserPromotionRepository  extends JpaRepository<UserPromotion, Long> {
    Optional<UserPromotion> findByUserIdAndPromotionCode(Long userId, String promotionCode);
}
