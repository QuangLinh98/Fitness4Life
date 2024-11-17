package fpt.aptech.userservice.dtos;

import lombok.Data;

@Data
public class MailEntity {
    private String email;
    private String subject;
    private String content;
}
