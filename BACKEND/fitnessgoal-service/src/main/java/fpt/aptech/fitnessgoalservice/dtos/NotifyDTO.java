package fpt.aptech.fitnessgoalservice.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NotifyDTO {
    private int itemId;
    private int userId;
    private String fullName;
    private String title;
    private String content;
}
