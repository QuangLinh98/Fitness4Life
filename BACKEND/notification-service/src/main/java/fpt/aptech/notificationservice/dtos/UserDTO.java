package fpt.aptech.notificationservice.dtos;

import lombok.Data;

@Data
public class UserDTO {
    private Long id;
    private String email;
    private String fullName;
}
