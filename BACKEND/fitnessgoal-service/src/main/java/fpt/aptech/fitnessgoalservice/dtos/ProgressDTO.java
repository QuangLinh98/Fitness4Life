package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.Goal;
import jakarta.persistence.Column;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ProgressDTO {
    private int userId;
    private int goal;

    @Column(nullable = false)
    private LocalDate trackingDate; // Ngày cập nhật

    @Column(nullable = false)
    private String metricName; // Chỉ số được cập nhật (VD: weight, body_fat, muscle_mass)

    @Column(nullable = false)
    private Double value; //Các Giá trị khác được cập nhật

    private Double weight; // Giá trị biến đổi được cập nhật sau mỗi lần tập luyện ( weight = 40kg)

    @Column(nullable = false)
    private double caloriesConsumed;   //Lượng calo tiêu thụ hàng ngày

    private LocalDateTime createdAt;
}
