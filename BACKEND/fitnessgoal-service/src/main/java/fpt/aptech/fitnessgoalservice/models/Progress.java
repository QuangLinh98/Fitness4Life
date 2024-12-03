package fpt.aptech.fitnessgoalservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "progress")
@Builder
public class Progress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private int userId;
    private String fullName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id", nullable = false)
    @JsonIgnore
    private Goal goal;

    @Column(nullable = false)
    private LocalDate trackingDate; // Ngày cập nhật dữ liệu

    @Enumerated(EnumType.STRING)
    private MetricName metricName; // Chỉ số được cập nhật

    private Double value; // Các Giá trị khác biến đổi được cập nhật sau mỗi lần tập luyện (vd : lượng cơ , lượng mỡ ,.. cho mục tiêu tăng cơ , giảm mỡ )
    private Double weight; // Giá trị biến đổi được cập nhật sau mỗi lần tập luyện ( weight = 40kg)

    @Column(nullable = false)
    private double caloriesConsumed;   //Lượng calo tiêu thụ hàng ngày
    @Column(length = 500)
    private String message; // Thông báo về calo thiếu/hợp lý/dư thừa (tuỳ chọn)

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
