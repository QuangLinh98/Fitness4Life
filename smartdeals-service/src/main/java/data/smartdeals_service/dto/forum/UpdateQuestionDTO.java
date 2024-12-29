package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.RolePost;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
@Data
public class UpdateQuestionDTO {
    private Long id;
    private String title;
    private String content;
    private String tag;
    private MultipartFile[] imageQuestionUrl;
    private List<Long> deleteImageUrl;
}
