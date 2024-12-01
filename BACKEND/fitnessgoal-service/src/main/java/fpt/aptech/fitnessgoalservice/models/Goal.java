package fpt.aptech.fitnessgoalservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "goals")
@Builder
public class Goal {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private int userId;
    private String fullName;

    @Enumerated(EnumType.STRING)
    private GoalType goalType;
    private Double targetValue;    // Giá trị mục tiêu (VD: cân nặng, % mỡ cơ thể)
    private Double currentValue;   // Giá trị hiện tại
    private LocalDate startDate;   //Ngày bắt đầu
    private LocalDate endDate;     //Ngày kết thúc

    @Enumerated(EnumType.STRING)
    private GoalStatus goalStatus;  //Trạng thái của mục tiêu

    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "goal")
    private List<GoalMetric>goalMetrics;

    @OneToMany(mappedBy = "goal")
    private List<Progress>progresses;

    @OneToMany(mappedBy = "goal")
    private List<Recommendation>recommendations;
}
