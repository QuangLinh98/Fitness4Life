package fpt.aptech.fitnessgoalservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "goal_metrics")
public class GoalMetric {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "goal_id", nullable = false)
    private Goal goal;

    @Column(nullable = false)
    private String metricName; // Tên chỉ số (VD: weight, body_fat, muscle_mass)
    private String metricUnit; // Đơn vị (VD: kg, %)
    private Double targetValue; // Giá trị mục tiêu
    private Double currentValue; // Giá trị hiện tại
}
