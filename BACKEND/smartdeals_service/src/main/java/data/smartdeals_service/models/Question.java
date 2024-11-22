package data.smartdeals_service.models;

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
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String title;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String author;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
