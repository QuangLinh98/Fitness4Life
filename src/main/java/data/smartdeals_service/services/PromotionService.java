package data.smartdeals_service.services;

import data.smartdeals_service.dto.PromotionDTO;
import data.smartdeals_service.dto.PromotionStatusDTO;
import data.smartdeals_service.models.Promotion;
import data.smartdeals_service.repository.PromotionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PromotionService {
    private final PromotionRepository promotionRepository;

    public List<Promotion> getAllPromotions() {
        return promotionRepository.findAll();
    }

    public Promotion createPromotion(PromotionDTO promotionDTO) {
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
        return promotionRepository.save(promotion);
    }
    public Promotion updatePromotion(Long id, PromotionDTO promotionDTO) {
        Promotion promotionById = promotionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Promotion not found with id: " + id));
        promotionById.setTitle(promotionDTO.getTitle());
        promotionById.setDescription(promotionDTO.getDescription());
        promotionById.setDiscountType(promotionDTO.getDiscountType());
        promotionById.setDiscountValue(promotionDTO.getDiscountValue());
        promotionById.setCustomerType(promotionDTO.getCustomerType());
        promotionById.setApplicableService(promotionDTO.getApplicableService());
        promotionById.setStartDate(promotionDTO.getStartDate());
        promotionById.setEndDate(promotionDTO.getEndDate());
        promotionById.setIsActive(promotionDTO.getIsActive());
        promotionById.setMinValue(promotionDTO.getMinValue());
        promotionById.setMaxUsage(promotionDTO.getMaxUsage());
        promotionById.setCreatedBy(promotionDTO.getCreatedBy());

        if (promotionById.getStartDate().isAfter(promotionById.getEndDate())) {
            throw new IllegalArgumentException("Start date must be before end date");
        }
        if (promotionById.getDiscountValue().compareTo(BigDecimal.ZERO) < 0
                || promotionById.getMinValue().compareTo(BigDecimal.ZERO) < 0
                || promotionById.getMaxUsage() < 0) {
            throw new IllegalArgumentException("Values for discount, minValue, or maxUsage cannot be negative");
        }


        return promotionRepository.save(promotionById);
    }

    public Optional<Promotion> getPromotionById(Long id) {
        return promotionRepository.findById(id);
    }

    public void deletePromotion(Long id) {
        promotionRepository.deleteById(id);
    }

    // Phương thức cập nhật trạng thái
    public Promotion closePromotionStatus(PromotionStatusDTO status) {
        Promotion promotion = promotionRepository.findById(status.getId())
                .orElseThrow(() -> new IllegalArgumentException("Promotion not found with id: " + status.getId()));
        promotion.setIsActive(status.getIsActive());
        return promotionRepository.save(promotion);
    }
}
