package fpt.aptech.dashboardservice.dtos;

import lombok.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Data

public class ClubImageDTO {
    private int clubId;
    private MultipartFile file;
    private boolean isPrimary = false;
    private LocalDateTime createdAt;
    private LocalDateTime updateAt;
}
