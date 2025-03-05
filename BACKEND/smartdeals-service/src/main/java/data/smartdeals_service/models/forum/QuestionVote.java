package data.smartdeals_service.models.forum;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "question_vote")
public class QuestionVote {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JsonIgnore
    @JoinColumn(name = "question_id", nullable = false)
    private Question question; // liên kết với câu hỏi

    private Long userId; // ID của user đã vote

    @Enumerated(EnumType.STRING)
    private VoteType voteType; // UPVOTE hoặc DOWNVOTE
}