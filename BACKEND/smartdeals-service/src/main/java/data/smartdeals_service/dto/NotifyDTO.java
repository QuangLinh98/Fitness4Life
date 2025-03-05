package data.smartdeals_service.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NotifyDTO {
    private long itemId;
    private long userId;
    private String fullName;
    private String title;
    private String content;
    private String token;
}
