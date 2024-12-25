package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.CategoryForum;
import data.smartdeals_service.models.forum.Question;
import data.smartdeals_service.models.forum.QuestionImage;
import data.smartdeals_service.models.forum.RolePost;
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
    private List<String> category; // Danh sách mô tả danh mục
    private Integer viewCount;
    private Integer upvote;
    private Integer downVote;
    private RolePost rolePost;
    private List<QuestionImage> questionImage;
    private LocalDateTime createdAt;

    public QuestionResponseDTO(Question question) {
        this.id = question.getId();
        this.author = question.getAuthor();
        this.title = question.getTitle();
        this.content = question.getContent();
        this.topic = question.getTopic();
        this.tag = question.getTag();
        this.category = question.getCategory() != null
                ? question.getCategory().stream().map(CategoryForum::getDescription).toList()
                : null;
        this.viewCount = question.getViewCount();
        this.upvote = question.getUpvote();
        this.downVote = question.getDownVote();
        this.createdAt = question.getCreatedAt();
        this.questionImage = question.getQuestionImage();
        this.rolePost = question.getRolePost();
    }
}


