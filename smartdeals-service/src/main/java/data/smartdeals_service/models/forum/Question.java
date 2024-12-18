package data.smartdeals_service.models.forum;

import com.fasterxml.jackson.annotation.JsonFormat;
import data.smartdeals_service.models.blog.BlogImage;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "questions")
public class Question {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long authorId; // id tác giả
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String author; // name tác giả
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String title; // tiêu đề bài viết
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content; // nội dung bài viết
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String topic; // chủ đề của câu hỏi
    @Column(nullable = false)
    private String tag; // từ khóa
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    @Enumerated(EnumType.STRING) // Lưu enum dưới dạng chuỗi trong DB
    private CategoryForum category; // danh mục câu hỏi
    private Integer viewCount = 0; //lượt xem
    private Integer upvote = 0; //like
    private Integer downVote = 0; //dislike
    private Integer answersCount = 0; //sô lượng câu trả lời cho câu hỏi
    private Boolean isPublished = true; // trạng thái của câu hỏi (chỉ admin và author)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt; // ngày tạo question
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt; // day update question
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastViewedAt; // last time view
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, mappedBy = "question")
    private List<QuestionImage> questionImage;

    @Transient // Không lưu vào cơ sở dữ liệu
    public String getCategoryDescription() {
        return category != null ? category.getDescription() : null;
    }
}
