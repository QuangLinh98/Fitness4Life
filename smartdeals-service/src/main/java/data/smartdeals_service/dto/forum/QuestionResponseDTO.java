package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.models.forum.QuestionImage;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class QuestionResponseDTO {
    private Long id;
    private String author;
    private String title;
    private String content;
    private String topic;
    private String tag;
    private String category; // Tên mô tả thay vì mã enum
    private Integer viewCount;
    private Integer upvote;
    private Integer downVote;
    private List<QuestionImage> questionImage;
    private LocalDateTime createdAt;

    public QuestionResponseDTO(Question question) {
        this.id = question.getId();
        this.author = question.getAuthor();
        this.title = question.getTitle();
        this.content = question.getContent();
        this.topic = question.getTopic();
        this.tag = question.getTag();
        this.category = question.getCategory() != null ? question.getCategory().getDescription() : null;
        this.viewCount = question.getViewCount();
        this.upvote = question.getUpvote();
        this.downVote = question.getDownVote();
        this.createdAt = question.getCreatedAt();
        this.questionImage = question.getQuestionImage();
    }
}

