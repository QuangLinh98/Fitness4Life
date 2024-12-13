package fpt.aptech.fitnessgoalservice.dtos;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DietPlanDTO {
    private int goal;

    private String mealType;
    private String mealDescription;
   // private double totalCalories;
    private double protein_ratio;   //Tỷ lệ protein trong chế độ ăn (%)
    private double carbs_ratio;
    private double fat_ratio;
    private LocalDateTime createAt;
}
