package data.smartdeals_service.dto;

import data.smartdeals_service.models.ApplicableServices;
import data.smartdeals_service.models.CustomerType;
import data.smartdeals_service.models.DiscountType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
