package data.smartdeals_service.models.promotion;
import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
@Data
@Entity
@Table(name = "promotions")
public class Promotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description; // mô tả

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DiscountType discountType;// loại khuyến mãi

    @Column(precision = 10, scale = 2)
    private BigDecimal discountValue; // giá trị giảm

    @Column(nullable = false)
    private LocalDateTime startDate;// ngày bắt đầu km

    @Column(nullable = false)
    private LocalDateTime endDate; // ngày kết thúc km

    @Column(nullable = false)
    private Boolean isActive; // trạng thái khuyến mãi

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ApplicableServices applicableService; // loại dịch vụ

    @Column(precision = 10, scale = 2)
    private BigDecimal minValue; //giá trị tối tiểu có thể áp mã

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CustomerType customerType; // loại khách

    private Integer maxUsage; // số lần dùng

    private LocalDateTime createdDate; //ngày tạo

    @Column(length = 255)
    private String createdBy; //người tạo
}
