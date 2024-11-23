package kj001.user_service.dtos;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserDTO {
    private String fullName;
    private String email;
}
