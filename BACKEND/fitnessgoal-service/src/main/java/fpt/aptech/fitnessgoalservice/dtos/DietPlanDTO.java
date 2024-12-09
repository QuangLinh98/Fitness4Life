package fpt.aptech.fitnessgoalservice.dtos;

import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.MealType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DietPlanDTO {
    private int goal;

    @Enumerated(EnumType.STRING)
    private MealType mealType;
    private String mealDescription;
   // private double totalCalories;
    private double protein_ratio;   //Tỷ lệ protein trong chế độ ăn (%)
    private double carbs_ratio;
    private double fat_ratio;
    private LocalDateTime createAt;
}
