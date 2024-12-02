package data.smartdeals_service.dto.blog;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateBlogDTO {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String tags;
    private MultipartFile[] thumbnailUrl;
    private List<Long> deleteImageUrl;
}
