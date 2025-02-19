package kj001.user_service.models;

import jakarta.persistence.*;
import jakarta.persistence.Table;
import lombok.*;
import org.hibernate.annotations.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "face_data")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class FaceData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "face_encoding", columnDefinition = "TEXT")
    private String faceEncoding;  // Base64 encoded face features

    @Column(name = "original_image_path")
    private String originalImagePath;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
