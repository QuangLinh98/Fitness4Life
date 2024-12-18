package data.smartdeals_service.services.user;

import data.smartdeals_service.models.user.UserPromotion;
import data.smartdeals_service.repository.userRepository.UserPromotionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserPromotionService {

    private final UserPromotionRepository userPromotionRepository;

}

