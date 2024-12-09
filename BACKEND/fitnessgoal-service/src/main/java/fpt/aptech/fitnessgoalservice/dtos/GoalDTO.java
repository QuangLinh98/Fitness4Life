package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.ActivityLevel;
import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import fpt.aptech.fitnessgoalservice.models.GoalType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class GoalDTO {
    @NotNull(message = "User Id type is required")
    private int userId;
    @NotNull(message = "Goal type is required")
    @Enumerated(EnumType.STRING)
    private GoalType goalType;

    @NotNull(message = "Target Value is required")
    private Double targetValue;    // Giá trị mục tiêu (VD: cân nặng, % mỡ cơ thể)
    @NotNull(message = "Current Value is required")
    private Double currentValue;   // Giá trị hiện tại
    private Double weight;
    @NotNull(message = "Start Date is required")
    private LocalDate startDate;   //Ngày bắt đầu
    @NotNull(message = "End Date is required")
    private LocalDate endDate;     //Ngày kết thúc

    @Enumerated(EnumType.STRING)
    private GoalStatus goalStatus;  //Trạng thái của mục tiêu

    @Enumerated(EnumType.STRING)
    @NotNull(message = "ActivityLevel is required")
    private ActivityLevel activityLevel;    //Mức độ hoạt động
    private LocalDateTime createdAt;
}
