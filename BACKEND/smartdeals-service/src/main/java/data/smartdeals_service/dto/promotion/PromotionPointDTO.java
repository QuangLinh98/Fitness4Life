package data.smartdeals_service.dto.promotion;

import com.fasterxml.jackson.annotation.JsonFormat;
import data.smartdeals_service.models.promotion.ApplicableServices;
import data.smartdeals_service.models.promotion.CustomerType;
import data.smartdeals_service.models.promotion.DiscountType;
import data.smartdeals_service.models.promotion.PackageName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class PromotionPointDTO {
    private String id;
    private String title;
    private String description;
    private List<DiscountType> discountType;
    private BigDecimal discountValue;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Boolean isActive;
    private List<ApplicableServices> applicableService;
    private BigDecimal minValue;
    private List<CustomerType> customerType;
    private String createdBy;
    private List<PackageName> packageName;
    private String code;
    private int points;
}
