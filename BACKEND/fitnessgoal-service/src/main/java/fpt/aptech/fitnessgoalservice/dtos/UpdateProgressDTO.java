package fpt.aptech.fitnessgoalservice.dtos;

import jakarta.persistence.Column;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class UpdateProgressDTO {
    private LocalDate trackingDate; // Ngày cập nhật

    @Column(nullable = false)
    private String metricName; // Chỉ số được cập nhật (VD: weight, body_fat, muscle_mass)

    private Double value; // Giá trị cập nhật

    private Double weight; // Giá trị biến đổi được cập nhật sau mỗi lần tập luyện ( weight = 40kg)

    @Column(nullable = false)
    private double caloriesConsumed;   //Lượng calo tiêu thụ hàng ngày
    private LocalDateTime updatedAt;
}
