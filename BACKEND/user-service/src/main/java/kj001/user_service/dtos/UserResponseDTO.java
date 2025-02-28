package kj001.user_service.dtos;

import jakarta.persistence.*;
import kj001.user_service.models.FaceData;
import kj001.user_service.models.Gender;
import kj001.user_service.models.Profile;
import kj001.user_service.models.Roles;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserResponseDTO {
    private long id;

    @Column(nullable = false)
    private String fullName;
    private int workoutPackageId;

    @Column(unique=true, nullable = false)
    private String email;

    private boolean isActive;
    private String phone;

    @Enumerated(EnumType.STRING)
    private Roles role;


    @Enumerated(EnumType.STRING)
    private Gender gender;

    private FaceDataDTO faceDataDTO;

    private ProfileDTO profileDTO;
}
