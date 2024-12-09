package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.DietPlanDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateDietPlanDTO;
import fpt.aptech.fitnessgoalservice.models.DietPlan;
import fpt.aptech.fitnessgoalservice.models.FoodItem;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.MealType;
import fpt.aptech.fitnessgoalservice.repository.DietPlanRepository;
import fpt.aptech.fitnessgoalservice.repository.FoodItemRepository;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DietPlanService {
    private final DietPlanRepository dietPlanRepository;
    private final FoodItemRepository foodItemRepository;
    private final GoalRepository goalRepository;

    //Handle get all data
    public List<DietPlan> getAll() {
        return dietPlanRepository.findAll();
    }

    public DietPlan getById(int id) {
        return dietPlanRepository.findById(id).get();
    }

    //Handle add a new diet plan for user
    public List<DietPlan> createDietPlanForUser(Goal goal) {
        Goal existingGoal = goalRepository.findById(goal.getId()).orElseThrow(() -> new RuntimeException("Goal not found"));

        //Tính toán và phân chia lượng calo dựa trên goalType
        double totalCaloriesPerMeal = existingGoal.getTargetCalories() / 3;

        // Tạo kế hoạch ăn uống cho từng bữa ăn
        List<DietPlan> dietPlans = new ArrayList<>();
        dietPlans.add(createDietPlanForMeal(existingGoal, MealType.BREAKFAST, getFoodItemsForMeal(totalCaloriesPerMeal, MealType.BREAKFAST), totalCaloriesPerMeal));
        dietPlans.add(createDietPlanForMeal(existingGoal, MealType.LUNCH, getFoodItemsForMeal(totalCaloriesPerMeal, MealType.LUNCH), totalCaloriesPerMeal));
        dietPlans.add(createDietPlanForMeal(existingGoal, MealType.DINNER, getFoodItemsForMeal(totalCaloriesPerMeal, MealType.DINNER), totalCaloriesPerMeal));

        return dietPlanRepository.saveAll(dietPlans);
    }

    //Phương thức tạo DietPlan cho các bữa ăn khác nhau
    private DietPlan createDietPlanForMeal(Goal goal, MealType mealType, List<FoodItem> foodItems, double totalCaloriesPerMeal) {
        // Chuyển chuỗi mealType thành enum MealType
//        MealType mealTypeEnum = MealType.valueOf(mealType);

        // Tính toán tỷ lệ dinh dưỡng dựa trên goalType
        double[] nutritionRatios = calculateNutritionRatios(String.valueOf(goal.getGoalType()));
        double proteinRatio = nutritionRatios[0];
        double carbsRatio = nutritionRatios[1];
        double fatRatio = nutritionRatios[2];

        //Tạo Diet Plan
        DietPlan newDietPlan = new DietPlan().builder()
                .goal(goal)
                .mealType(mealType)
                .mealDescription("Plan for " + mealType)
                .totalCalories(totalCaloriesPerMeal)
                .protein_ratio(proteinRatio)
                .carbs_ratio(carbsRatio)
                .fat_ratio(fatRatio)
                .foodItems(foodItems)
                .createAt(LocalDateTime.now())
                .build();
        return dietPlanRepository.save(newDietPlan);
    }

    //Tính toán tỷ lệ dinh dưỡng dựa trên loại mục tiêu.
    private double[] calculateNutritionRatios(String goalType) {
        double proteinRatio, carbsRatio, fatRatio;

        switch (goalType) {
            case "WEIGHT_LOSS":
                // Tính toán tỷ lệ dinh dưỡng cho giảm cân
                proteinRatio = 40;
                carbsRatio = 30;
                fatRatio = 30;
                break;

            case "WEIGHT_GAIN":
                // Tính toán tỷ lệ dinh dưỡng cho tăng cân
                proteinRatio = 30;
                carbsRatio = 40;
                fatRatio = 30;
                break;

            case "MUSCLE_GAIN":
                // Tính toán tỷ lệ dinh dưỡng cho tăng cơ
                proteinRatio = 35;
                carbsRatio = 35;
                fatRatio = 30;
                break;

            case "FAT_LOSS":
                // Tính toán tỷ lệ dinh dưỡng cho giảm mỡ
                proteinRatio = 45;
                carbsRatio = 25;
                fatRatio = 30;
                break;

            case "MAINTENANCE":
                // Tính toán tỷ lệ dinh dưỡng cho duy trì cân nặng
                proteinRatio = 33;
                carbsRatio = 33;
                fatRatio = 34;
                break;

            default:
                throw new RuntimeException("Unknown goal type: " + goalType);
        }
        return new double[]{proteinRatio, carbsRatio, fatRatio};
    }

    //Phương thức lấy danh sách FoodItem cho bữa ăn dựa trên lượng calo
    private List<FoodItem> getFoodItemsForMeal(double mealCalories, MealType mealType) {
        List<FoodItem> foodItemList = foodItemRepository.findByDietPlan_MealType(mealType);
        List<FoodItem> foodItems = new ArrayList<>();
        double currentCalories = 0.0;
        //Duyệt qua các món ăn và chọn món sao cho tổng calo gần bằng mealCalories
        for (FoodItem foodItem : foodItemList) {
            if (currentCalories + foodItem.getCalories() <= mealCalories) {
                foodItems.add(foodItem);  // Thêm món ăn vào danh sách
                currentCalories += foodItem.getCalories();  // Cập nhật tổng calo đã chọn
            }
            if (currentCalories >= mealCalories) {
                break; //Dừng khi đã đủ tổng lượng calo cho bữa ăn và break;
            }
        }
        return foodItems;
    }

    //Handle edit a dietPlan
    public DietPlan updateDietPlan(int id, UpdateDietPlanDTO dietPlanDTO) {
        DietPlan existingDiet = dietPlanRepository.findById(id).get();
        if (existingDiet == null) {
            throw new RuntimeException("Diet plan not found");
        }
        existingDiet.setMealType(dietPlanDTO.getMealType());
        existingDiet.setMealDescription(dietPlanDTO.getMealDescription());
        existingDiet.setTotalCalories(dietPlanDTO.getTotalCalories());
        existingDiet.setProtein_ratio(dietPlanDTO.getProtein_ratio());
        existingDiet.setCarbs_ratio(dietPlanDTO.getCarbs_ratio());
        existingDiet.setFat_ratio(dietPlanDTO.getFat_ratio());
        existingDiet.setUpdateAt(LocalDateTime.now());

        return dietPlanRepository.save(existingDiet);
    }

    //Handle delete DietPlan
    public DietPlan deleteDietPlan(int id) {
        DietPlan existingDiet = dietPlanRepository.findById(id).get();
        if (existingDiet == null) {
            throw new RuntimeException("Diet plan not found");
        }
        dietPlanRepository.delete(existingDiet);
        return existingDiet;
    }

}