package kj001.user_service.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class FaceDataDTO {
    private Long userId;
    private String faceEncoding;
    private MultipartFile faceImage;  // Used for request only
    private String originalImagePath;
    private boolean hasFaceData;
}