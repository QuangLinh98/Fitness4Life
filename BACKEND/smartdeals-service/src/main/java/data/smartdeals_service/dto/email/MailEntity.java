package data.smartdeals_service.dto.email;

import lombok.Data;

@Data
public class MailEntity {
    private String email;
    private String subject;
    private String content;
}
