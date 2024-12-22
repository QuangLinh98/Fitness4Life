package data.smartdeals_service.dto.comment;

import data.smartdeals_service.models.comment.Comment;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GetCommentDTO {
    private Long id;
    private Long userId;
    private String userName;
    private String content;
    private Long questionId; // Chỉ lấy ID của question
    private Long blogId; // Chỉ lấy ID của blog
    private Long parentCommentId; // Chỉ lấy ID của comment cha
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isPublished;
    private List<GetCommentDTO> replies;

    public GetCommentDTO(Comment comment) {
        this.id = comment.getId();
        this.userId = comment.getUserId();
        this.userName = comment.getUserName();
        this.content = comment.getContent();
        this.createdAt = comment.getCreatedAt();
        this.updatedAt = comment.getUpdatedAt();
        this.isPublished = comment.getIsPublished();
        this.parentCommentId = comment.getParentComment() != null ? comment.getParentComment().getId() : null;
        this.questionId = comment.getQuestion() != null ? comment.getQuestion().getId() : null;
        this.blogId = comment.getBlog() != null ? comment.getBlog().getId() : null;
        this.replies = comment.getReplies() != null
                ? comment.getReplies().stream().map(GetCommentDTO::new).collect(Collectors.toList())
                : null;
    }
}
