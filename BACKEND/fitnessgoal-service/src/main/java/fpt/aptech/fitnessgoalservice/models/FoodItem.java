package fpt.aptech.fitnessgoalservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "food_items")
@Builder
public class FoodItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "diet_id",nullable = false)
    @JsonIgnore
    private DietPlan dietPlan;

    private String foodName;
    private int quantity;
    private double calories;   //Số calo trong thực phẩm
    private double protein;    //Lượng protein trong thực phẩm
    private double carbs;
    private double fat;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
