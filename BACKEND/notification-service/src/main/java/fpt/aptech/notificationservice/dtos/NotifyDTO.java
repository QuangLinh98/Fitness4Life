package fpt.aptech.notificationservice.dtos;

import lombok.*;

@Data
public class NotifyDTO {
    private int itemId;
    private Long userId;
    private String fullName;
    private String title;
    private String content;
}