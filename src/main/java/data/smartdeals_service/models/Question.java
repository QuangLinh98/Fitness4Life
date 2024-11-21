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
    private String title;
    private String content;
    private String author;
    private LocalDateTime createdAt;
}
