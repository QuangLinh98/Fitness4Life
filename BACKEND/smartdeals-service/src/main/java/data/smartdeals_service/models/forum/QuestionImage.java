package data.smartdeals_service.models.forum;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "question_images")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class QuestionImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String imageUrl;
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;
}
