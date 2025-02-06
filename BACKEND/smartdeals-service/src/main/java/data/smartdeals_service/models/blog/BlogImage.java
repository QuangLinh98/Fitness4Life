package data.smartdeals_service.models.blog;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "blog_images")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class BlogImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String imageUrl;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "blog_id", nullable = false)
    private Blog blog;
}
