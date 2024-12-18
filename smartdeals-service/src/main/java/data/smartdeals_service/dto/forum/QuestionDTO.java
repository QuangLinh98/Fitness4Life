package data.smartdeals_service.dto.forum;

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
    private String topic;
    private String tag;
    private String category;
    private List<MultipartFile> imageQuestionUrl;
}
