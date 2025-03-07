package kj001.user_service.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FaceDataReponse {
    private Long faceId;
    private Long userId;
    private String username;
    private String email;
    private String imageUrl;
    private LocalDateTime registeredAt;
}
