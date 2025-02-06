package data.smartdeals_service.repository.forumRepositories;

import data.smartdeals_service.models.forum.QuestionView;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuestionViewRepository extends JpaRepository<QuestionView, Long> {
    Optional<QuestionView> findByQuestionIdAndUserId(Long questionId, Long userId);
}