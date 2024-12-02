package data.smartdeals_service.dto.forum;

import lombok.Data;

@Data
public class QuestionDTO {
    private Long authorId;
    private String author;
    private String title;
    private String content;

}
