package data.smartdeals_service.dto;

import lombok.Data;

@Data
public class CreateQuestionDTO {
    private String title;
    private String content;
    private String author;
}
