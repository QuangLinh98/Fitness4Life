package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.Gender;
import lombok.Data;

@Data
public class UserDTO {
    private String fullName;
    private String email;
    private Gender gender;

    private ProfileUserDTO profileUserDTO;
}
