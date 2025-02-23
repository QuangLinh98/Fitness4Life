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
@Table(name = "goal_extensions")
@Builder
public class GoalExtension {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id", nullable = false)
    @JsonIgnore
    private Goal goal;

    @Column(nullable = false)
    private LocalDate originalEndTime; // Ngày kết thúc ban đầu

    @Column(nullable = false)
    private LocalDate newEndTime; // Ngày kết thúc mới sau gia hạn

    private boolean userResponse; // Phản hồi của user (true: đồng ý, false: từ chối)

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt; // Ngày gia hạn
}
