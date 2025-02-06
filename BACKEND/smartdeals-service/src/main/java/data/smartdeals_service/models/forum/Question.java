package data.smartdeals_service.models.forum;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "question_forum")
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

    @Column(nullable = false)
    private String tag; // từ khóa

    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    @Enumerated(EnumType.STRING) // Lưu enum dưới dạng chuỗi trong DB
    @ElementCollection(fetch = FetchType.EAGER) // Lấy toàn bộ dữ liệu danh sách khi truy vấn
    @CollectionTable(name = "category_list", joinColumns = @JoinColumn(name = "question_forum_id"))
    private List<CategoryForum> category; // danh mục câu hỏi

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<QuestionView> questionViews;

    private Integer viewCount = 0; //lượt xem

    private Integer answersCount = 0; //sô lượng câu trả lời cho câu hỏi

    @Enumerated(EnumType.STRING)
    private PostStatus status;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt; // ngày tạo question

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt; // day update question

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastViewedAt; // last time view

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, mappedBy = "question")
    private List<QuestionImage> questionImage;

    @Enumerated(EnumType.STRING)
    private RolePost rolePost;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<QuestionVote> votes;
    private Integer upvote = 0;
    private Integer downVote = 0;
}
