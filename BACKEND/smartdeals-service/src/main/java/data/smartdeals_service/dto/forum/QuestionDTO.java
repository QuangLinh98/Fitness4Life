package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.PostStatus;
import data.smartdeals_service.models.forum.RolePost;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class QuestionDTO {
    private Long id;
    private Long authorId;
    private String author;
    private String title;
    private String content;
    private String tag;
    private PostStatus status;
    private List<String> category; // Danh sách mã enum
    private RolePost rolePost;
    private List<MultipartFile> imageQuestionUrl;
}
