package data.smartdeals_service.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

    @Entity
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Table(name = "comments")
    public class Comment {
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @ManyToOne
        @JsonIgnore
        @JoinColumn(name = "blog_id", nullable = false)
        private Blog blog;  // Liên kết với bảng Blog

        @ManyToOne
        @JsonIgnore
        @JoinColumn(name = "parent_comment_id")
        private Comment parentComment;

        @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
        private String content;

        private Long authorId;

        @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
        private String authorName;

        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        private Boolean isPublished;
    }
