package fpt.aptech.notificationservice.mail;

import lombok.Data;

@Data
public class MailEntity {
    private String email;
    private String subject;
    private String content;
}
