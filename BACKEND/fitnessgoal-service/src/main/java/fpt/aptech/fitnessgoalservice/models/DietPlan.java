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
@Table(name = "diet_plan")
@Builder
public class DietPlan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "goal_id", nullable = false)
    @JsonIgnore
    private Goal goal;

    @Enumerated(EnumType.STRING)
    private MealType mealType;
    private String mealDescription;
    private double totalCalories;
    private double protein_ratio;   //Tỷ lệ protein trong chế độ ăn (%)
    private double carbs_ratio;
    private double fat_ratio;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    @OneToMany(mappedBy = "dietPlan")
    private List<FoodItem>foodItems;
}
