package fpt.aptech.fitnessgoalservice.dtos;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UpdateDietPlanDTO {
    private String mealType;
    private String mealDescription;
    private double totalCalories;
    private double protein_ratio;   //Tỷ lệ protein trong chế độ ăn (%)
    private double carbs_ratio;
    private double fat_ratio;
    private LocalDateTime updateAt;
}
