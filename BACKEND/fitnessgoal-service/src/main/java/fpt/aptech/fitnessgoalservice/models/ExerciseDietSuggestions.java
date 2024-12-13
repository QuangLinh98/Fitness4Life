package fpt.aptech.fitnessgoalservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "suggestions")
@Builder
public class ExerciseDietSuggestions {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id", nullable = false)
    @JsonIgnore
    private Goal goal;

    @Column(name = "diet_plan", columnDefinition = "TEXT")
    private String dietPlan;
    @Column(name = "workout_plan", columnDefinition = "TEXT")
    private String workoutPlan;
}
