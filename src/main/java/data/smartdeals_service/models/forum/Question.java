package data.smartdeals_service.models.forum;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "questions")
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long authorId;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String author;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String title;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
