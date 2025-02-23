package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.MetricName;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ProgressDTO {
    private int userId;
    private int goal;

    @Column(nullable = false)
    private LocalDate trackingDate; // Ngày cập nhật

    @Enumerated(EnumType.STRING)
    @NotNull
    private MetricName metricName; // Chỉ số được cập nhật

    @Column(nullable = false)
    private Double value; //Các Giá trị khác được cập nhật

    private Double weight; // Giá trị biến đổi được cập nhật sau mỗi lần tập luyện ( weight = 40kg)

    @Column(nullable = false)
    private double caloriesConsumed;   //Lượng calo tiêu thụ hàng ngày

    private LocalDateTime createdAt;
}
