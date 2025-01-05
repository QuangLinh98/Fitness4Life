package data.smartdeals_service.dto.forum;

import data.smartdeals_service.models.forum.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class QuestionResponseDTO {
    private Long id;
    private String author;
    private Long authorId;
    private String title;
    private String content;
    private String tag;
    private List<String> category; // Danh sách mô tả danh mục
    private Integer viewCount;
    private Integer upvote;
    private Integer downVote;
    private RolePost rolePost;
    private PostStatus status;
    private List<QuestionImage> questionImage;
    private LocalDateTime createdAt;

    public QuestionResponseDTO(Question question) {
        this.id = question.getId();
        this.author = question.getAuthor();
        this.authorId = question.getAuthorId();
        this.title = question.getTitle();
        this.content = question.getContent();
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
        this.status = question.getStatus();
    }
}


