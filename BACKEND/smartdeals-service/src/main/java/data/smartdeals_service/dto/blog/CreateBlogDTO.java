package data.smartdeals_service.dto.blog;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateBlogDTO {
    private String authorName;
    private String title;
    private String content;
    private String category;
    private String tags;
    private List<MultipartFile> thumbnailUrl;
}
