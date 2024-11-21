package data.smartdeals_service.repository;

import data.smartdeals_service.models.CommentForum;
import data.smartdeals_service.models.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface CommentForumRepository extends JpaRepository<CommentForum, Long> {
    List<CommentForum> findByQuestionAndParentCommentIsNull(Question question);
    List<CommentForum> findByParentComment(CommentForum parentComment);
}
