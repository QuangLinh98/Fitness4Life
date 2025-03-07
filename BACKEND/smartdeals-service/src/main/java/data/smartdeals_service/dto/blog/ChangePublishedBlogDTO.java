package data.smartdeals_service.dto.blog;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChangePublishedBlogDTO{
    @NotNull(message = "Published status is required")
    private Boolean isPublished;
}