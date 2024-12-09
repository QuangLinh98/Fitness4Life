package fpt.aptech.fitnessgoalservice.dtos;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UpdateFoodItemDTO {
    private String foodName;
    private int quantity;
    private double calories;   //Số calo trong thực phẩm
    private double protein;    //Lượng protein trong thực phẩm
    private double carbs;
    private double fat;
    private LocalDateTime updateAt;
}
