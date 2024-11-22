package fpt.aptech.dashboardservice.dtos;

import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.ScheduleTrainer;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.*;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class TrainerDTO {
    @NotNull(message = "Branch must not be null")
    private int branch;
    @NotBlank(message = "Full name must not be empty")
    @Size(min = 3, max = 100, message = "Full name must be between 3 and 100 characters")
    private String fullName;
    private String slug;
    private MultipartFile file;
    @NotBlank(message = "Specialization must not be empty")
    private String specialization;
    @DecimalMin(value = "0", message = "Experience year must be greater than or equal to 0")
    private double experienceYear;
    @NotBlank(message = "Certificate must not be empty")
    private String certificate;
    @NotBlank(message = "Phone number must not be empty")
    private String phoneNumber;
    @NotEmpty(message = "Schedule must not be empty")
    @ElementCollection(targetClass = ScheduleTrainer.class)
    @Enumerated(EnumType.STRING)
    private List<ScheduleTrainer> scheduleTrainers;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
