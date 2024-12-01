package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.GoalType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class UpdateGoalDTO {
    @NotNull(message = "Goal type is required")
    @Enumerated(EnumType.STRING)
    private GoalType goalType;

    @NotNull(message = "Height Value is required")
    private int heightValue;    //Giá trị chiều cao

    @NotNull(message = "Target Value is required")
    private Double targetValue;    // Giá trị mục tiêu (VD: cân nặng, % mỡ cơ thể)
    @NotNull(message = "Current Value is required")
    private Double currentValue;   // Giá trị hiện tại
    @NotNull(message = "Start Date is required")
    private LocalDate startDate;   //Ngày bắt đầu
    @NotNull(message = "End Date is required")
    private LocalDate endDate;     //Ngày kết thúc
}
