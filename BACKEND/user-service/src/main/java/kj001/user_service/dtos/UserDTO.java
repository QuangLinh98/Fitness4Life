package kj001.user_service.dtos;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import kj001.user_service.models.Gender;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserDTO {
    private Long id;
    private String fullName;
    private String email;
    @Enumerated(EnumType.STRING)
    private Gender gender;
    private ProfileUserDTO  profileUserDTO;
}
