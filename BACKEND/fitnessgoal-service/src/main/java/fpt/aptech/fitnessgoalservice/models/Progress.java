package fpt.aptech.fitnessgoalservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "progress")
public class Progress {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "goal_id", nullable = false)
    private Goal goal;

    @Column(nullable = false)
    private LocalDate trackingDate; // Ngày cập nhật

    @Column(nullable = false)
    private String metricName; // Chỉ số được cập nhật (VD: weight, body_fat, muscle_mass)

    @Column(nullable = false)
    private Double value; // Giá trị cập nhật

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
}
