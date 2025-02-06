package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.PostStatus;
import lombok.Data;

@Data
public class QuestionStatusDTO {
    private PostStatus status;
}
