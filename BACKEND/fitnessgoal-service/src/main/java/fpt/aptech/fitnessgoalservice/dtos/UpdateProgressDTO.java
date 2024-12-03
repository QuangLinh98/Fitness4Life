package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.MetricName;
import jakarta.persistence.Column;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class UpdateProgressDTO {
    private int goalId;
    private LocalDate trackingDate; // Ngày cập nhật

    @Enumerated(EnumType.STRING)
    @NotNull
    private MetricName metricName; // Chỉ số được cập nhật

    private Double value; // Giá trị cập nhật

    private Double weight; // Giá trị biến đổi được cập nhật sau mỗi lần tập luyện ( weight = 40kg)

    @Column(nullable = false)
    private double caloriesConsumed;   //Lượng calo tiêu thụ hàng ngày
    private LocalDateTime updatedAt;
}
