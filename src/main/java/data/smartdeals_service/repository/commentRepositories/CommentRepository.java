package data.smartdeals_service.repository.commentRepositories;

import data.smartdeals_service.models.comment.Comment;
import data.smartdeals_service.models.forum.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CommentRepository extends JpaRepository<Comment, Long> {
    Optional<Comment> findById(Long id);

    List<Comment> findByBlogId(Long blogId);

    List<Comment> findByParentCommentId(Long parentCommentId);

    List<Comment> findByQuestionAndParentCommentIsNull(Question question);

    List<Comment> findByParentComment(Comment parentComment);
}
