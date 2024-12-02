package data.smartdeals_service.repository.forumRepositories;

import data.smartdeals_service.models.forum.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
}
