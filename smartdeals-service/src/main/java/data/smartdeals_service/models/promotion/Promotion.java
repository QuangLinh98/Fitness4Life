package data.smartdeals_service.models.promotion;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

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
    @ElementCollection(fetch = FetchType.EAGER) // Lấy toàn bộ dữ liệu danh sách khi truy vấn
    @CollectionTable(name = "promotion_discountType", joinColumns = @JoinColumn(name = "promotion_id"))
    @Column(nullable = false)
    private List<DiscountType> discountType;// loại khuyến mãi

    @Column(precision = 10, scale = 2)
    private BigDecimal discountValue; // số tiền được giảm

    @Column(nullable = false)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startDate;// ngày bắt đầu km

    @Column(nullable = false)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endDate; // ngày kết thúc km

    @Column(nullable = false)
    private Boolean isActive; // trạng thái khuyến mãi

    @Enumerated(EnumType.STRING)
    @ElementCollection(fetch = FetchType.EAGER) // Lấy toàn bộ dữ liệu danh sách khi truy vấn
    @CollectionTable(name = "promotion_services", joinColumns = @JoinColumn(name = "promotion_id"))
    @Column(nullable = false)
    private List<ApplicableServices> applicableService; // Nhiều loại dịch vụ

    @Column(precision = 10, scale = 2)
    private BigDecimal minValue; //mức tiền để đáp ứng điều kiện giảm

    @Enumerated(EnumType.STRING)
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "promotion_customer_types", joinColumns = @JoinColumn(name = "promotion_id"))
    @Column(nullable = false)
    private List<CustomerType> customerType; // Nhiều loại khách hàng

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdDate; //ngày tạo

    private LocalDateTime updatedAt;

    @Column(length = 255)
    private String createdBy; //người tạo

    @Enumerated(EnumType.STRING)
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "promotion_packageName", joinColumns = @JoinColumn(name = "promotion_id"))
    @Column(nullable = false)
    private List<PackageName> packageName;   // Tên membership

    @Column(unique = true)
    private String code; // Unique 8-character code
}
