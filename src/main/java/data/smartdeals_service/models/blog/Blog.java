package data.smartdeals_service.models.blog;

import data.smartdeals_service.models.comment.Comment;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "blogs")
public class Blog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String authorName;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String title;
    @Lob
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String category;
    @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String tags;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isPublished;
    private Integer viewCount = 0;
    private Integer likesCount = 0;
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, mappedBy = "blog")
    private List<BlogImage> thumbnailUrl;

    @OneToMany(mappedBy = "blog", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comment> comments;  // Liên kết với bảng Comment
}


