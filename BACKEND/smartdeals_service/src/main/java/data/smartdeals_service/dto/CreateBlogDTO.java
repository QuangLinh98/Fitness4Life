package data.smartdeals_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateBlogDTO {
    private Long authorId;
    private String authorName;
    private String title;
    private String content;
    private String category;
    private String tags;
    private List<MultipartFile> thumbnailUrl;
}
