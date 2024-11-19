package fpt.aptech.dashboardservice.dtos;

import fpt.aptech.dashboardservice.models.PackageName;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class WorkoutPackageDTO {
    @NotNull(message = "User ID cannot be null")
    private int userId;
    @NotNull(message = "Package name cannot be null")
    private PackageName packageName;
    @NotEmpty(message = "Description cannot be empty")
    private String description;
    @NotNull(message = "Duration month name cannot be null")
    private int durationMonth;
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be greater than 0")
    private double price;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
