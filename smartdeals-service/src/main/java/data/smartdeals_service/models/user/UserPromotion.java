package data.smartdeals_service.models.user;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserPromotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId; // ID của user (từ user-service)
    private String promotionCode; // Mã promotion

    private Boolean isUsed = false; // Trạng thái đã sử dụng hay chưa
    private LocalDateTime usedAt; // Thời gian sử dụng (nếu có)
}

