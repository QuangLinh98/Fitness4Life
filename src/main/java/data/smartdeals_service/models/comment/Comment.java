package data.smartdeals_service.models.comment;

import com.fasterxml.jackson.annotation.JsonIgnore;
import data.smartdeals_service.models.blog.Blog;
import data.smartdeals_service.models.forum.Question;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

    @Entity
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Table(name = "comments")
    public class Comment {
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id; // khóa chính

        private Long userId;

        @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
        private String userName;

        @ManyToOne
        @JsonIgnore
        @JoinColumn(name = "blog_id", nullable = true)
        private Blog blog;  // Liên kết với bảng Blog

        @ManyToOne
        @JsonIgnore
        @JoinColumn(name = "question_id", nullable = true)
        private Question question; // liên kết với bảng question

        @ManyToOne
        @JsonIgnore
        @JoinColumn(name = "parent_id", nullable = true)
        private Comment parentComment; // liên kết với bình luận cha nếu có

        @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
        private String content;

        private LocalDateTime createdAt;

        private LocalDateTime updatedAt;

        private Boolean isPublished;

        @OneToMany(mappedBy = "parentComment", cascade = CascadeType.ALL)
        private List<Comment> replies = new ArrayList<>(); // Các câu trả lời con
    }
