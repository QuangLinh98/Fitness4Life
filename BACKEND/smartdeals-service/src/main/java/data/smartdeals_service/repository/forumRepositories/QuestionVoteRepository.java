package data.smartdeals_service.repository.forumRepositories;

import data.smartdeals_service.models.forum.QuestionVote;
import data.smartdeals_service.models.forum.VoteType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QuestionVoteRepository extends JpaRepository<QuestionVote, Long> {
    Optional<QuestionVote> findByQuestionIdAndUserId(Long questionId, Long userId);
}

