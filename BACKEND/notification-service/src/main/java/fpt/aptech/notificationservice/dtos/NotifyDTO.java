package fpt.aptech.notificationservice.dtos;

import lombok.*;

@Data
public class NotifyDTO {
    private int itemId;
    private int userId;
    private String fullName;
    private String title;
    private String content;
   // private String token;
}
