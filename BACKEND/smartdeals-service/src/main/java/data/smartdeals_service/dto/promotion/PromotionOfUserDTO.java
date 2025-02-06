package data.smartdeals_service.dto.promotion;

import com.fasterxml.jackson.annotation.JsonFormat;
import data.smartdeals_service.models.promotion.ApplicableServices;
import data.smartdeals_service.models.promotion.CustomerType;
import data.smartdeals_service.models.promotion.DiscountType;
import data.smartdeals_service.models.promotion.PackageName;
import jakarta.persistence.Column;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class PromotionOfUserDTO {
    private Long id;
    private Long userId;
    private String title;
    private String description;
    private BigDecimal discountValue;
    private List<DiscountType> discountType;
    private List<ApplicableServices> applicableService;
    private List<CustomerType> customerType;
    private List<PackageName> packageName;
    private BigDecimal minValue;
    private String code;
    private Long promotionAmount;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startDate;// ngày bắt đầu km
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endDate; // ngày kết thúc km
    private Boolean isUsed;
    private String createdBy;
}
