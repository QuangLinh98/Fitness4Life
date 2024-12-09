package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.FoodItemDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateFoodItemDTO;
import fpt.aptech.fitnessgoalservice.models.DietPlan;
import fpt.aptech.fitnessgoalservice.models.FoodItem;
import fpt.aptech.fitnessgoalservice.repository.DietPlanRepository;
import fpt.aptech.fitnessgoalservice.repository.FoodItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodItemService {
    private final FoodItemRepository foodItemRepository;
    private final DietPlanRepository dietPlanRepository;

    //Handle get all data
    public List<FoodItem> findAll() {
        return foodItemRepository.findAll();
    }

    //Hande get one foodItem
    public FoodItem findById(int id) {
        return foodItemRepository.findById(id).orElse(null);
    }

    //Handel add a new foodItem
    public FoodItem createFoodItem(FoodItemDTO foodItemDTO) {
        DietPlan existingDietPlan = dietPlanRepository.findById(foodItemDTO.getDietPlan()).orElseThrow(() -> new RuntimeException("Diet plan not found"));
        FoodItem newFoodItem = new FoodItem().builder()
                .dietPlan(existingDietPlan)
                .foodName(foodItemDTO.getFoodName())
                .quantity(foodItemDTO.getQuantity())
                .calories(foodItemDTO.getCalories())
                .protein(foodItemDTO.getProtein())
                .carbs(foodItemDTO.getCarbs())
                .fat(foodItemDTO.getFat())
                .createAt(LocalDateTime.now())
                .build();
        return foodItemRepository.save(newFoodItem);
    }

    //Handle edit a foodItem
    public FoodItem updateFoodItem(int id , UpdateFoodItemDTO foodItemDTO) {
        FoodItem existingFoodItem = foodItemRepository.findById(id).get();
        if (existingFoodItem == null) {
            throw new RuntimeException("Food item not found");
        }
        existingFoodItem.setFoodName(foodItemDTO.getFoodName());
        existingFoodItem.setQuantity(foodItemDTO.getQuantity());
        existingFoodItem.setCalories(foodItemDTO.getCalories());
        existingFoodItem.setCarbs(foodItemDTO.getCarbs());
        existingFoodItem.setProtein(foodItemDTO.getProtein());
        existingFoodItem.setFat(foodItemDTO.getFat());
        existingFoodItem.setUpdateAt(LocalDateTime.now());

        return foodItemRepository.save(existingFoodItem);
    }

    //Handle delete Food Item
    public FoodItem deleteFoodItem(int id) {
        FoodItem existingFoodItem = foodItemRepository.findById(id).get();
        if (existingFoodItem == null) {
            throw new RuntimeException("Food Item not found");
        }
        foodItemRepository.delete(existingFoodItem);
        return existingFoodItem;
    }
}
