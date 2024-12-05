package fpt.aptech.fitnessgoalservice.dtos;

import lombok.Builder;
import lombok.Data;


@Data
@Builder
public class NotifyDTO {
    private int itemId;
    private int userId;
    private String fullName;
    private String title;
    private String content;
}
