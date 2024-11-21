package data.smartdeals_service.models;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table(name = "comment_forums")
public class CommentForum {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "question_id")
    private Question question;

    @ManyToOne
    @JsonIgnore
    @JoinColumn(name = "parent_id")
    private CommentForum parentComment; // Liên kết với bình luận cha (nếu có)

    private String content; // Nội dung bình luận
    private String author; // Tác giả
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "parentComment", cascade = CascadeType.ALL)
    private List<CommentForum> replies = new ArrayList<>(); // Các câu trả lời con
}
