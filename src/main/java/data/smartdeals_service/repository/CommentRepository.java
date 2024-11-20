package data.smartdeals_service.repository;

import data.smartdeals_service.models.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CommentRepository extends JpaRepository<Comment, Long> {
    // Tìm bình luận theo id
    Optional<Comment> findById(Long id);

    // Tìm tất cả bình luận của một blog
    List<Comment> findByBlogId(Long blogId);

    // Tìm bình luận con của bình luận cha
    List<Comment> findByParentCommentId(Long parentCommentId);
}
