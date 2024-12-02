package data.smartdeals_service.dto.promotion;

import data.smartdeals_service.models.promotion.ApplicableServices;
import data.smartdeals_service.models.promotion.CustomerType;
import data.smartdeals_service.models.promotion.DiscountType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
@Data
public class PromotionDTO {
    private String title;
    private String description;
    private DiscountType discountType;
    private BigDecimal discountValue;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Boolean isActive;
    private ApplicableServices applicableService;
    private BigDecimal minValue;
    private CustomerType customerType;
    private Integer maxUsage;
    private String createdBy;
}
