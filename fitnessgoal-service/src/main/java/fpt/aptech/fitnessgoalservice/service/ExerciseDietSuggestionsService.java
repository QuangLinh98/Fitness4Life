package fpt.aptech.fitnessgoalservice.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.models.*;
import fpt.aptech.fitnessgoalservice.repository.ExerciseDietSuggestionsRepository;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ExerciseDietSuggestionsService {
    private final ExerciseDietSuggestionsRepository exerciseDietSuggestionsRepository;
    private final GoalRepository goalRepository;
    private final GoogleApiClient googleApiClient;

    //Handle get all data
    public List<ExerciseDietSuggestions> getAll() {
        return exerciseDietSuggestionsRepository.findAll();
    }

    public ExerciseDietSuggestions getById(int id) {
        return exerciseDietSuggestionsRepository.findById(id).get();
    }


    //Tạo chế độ ăn uống dựa trên mục tiêu của người dùng'
    public ExerciseDietSuggestions generateDietPlan(UserDTO userDTO, Goal goal) {
        Goal existingGoal = goalRepository.findById(goal.getId()).orElseThrow(() -> new RuntimeException("Goal not found"));

        try {
            //1. Gửi yêu cầu tới API của Google để nhận kế hoạch chế độ ăn
            String content = createInputTextForGoogle(userDTO, goal);  //Tạo câu lệnh gửi tới API google
            String googleResponse = googleApiClient.getDietPlanFromGoogle(content);  // Gửi yêu cầu tới API Google
            System.out.println("googleResponse: " + googleResponse);

            if (googleResponse != null && googleResponse.contains("candidates")) {
                JsonNode candidates = new ObjectMapper().readTree(googleResponse).path("candidates").get(0); // Lấy ứng viên đầu tiên
                JsonNode textNode = candidates.get("content").get("parts").get(0).get("text"); // Lấy text từ phản hôi

                if (textNode != null) {
                    String fullText = textNode.asText(); // Lấy nội dung tòan bộ kế hoạch từ API
                    System.out.println("Full Text: " + fullText);

                    // Tách ra phần kế hoạch ăn uống và luyện tập
                    String dietPlan = "No diet plan provided";
                    String workoutPlan = "No workout plan provided";

                    if (fullText.contains("Workout Plan")) {
                        // Sử dụng regex hoặc split để tách phần kế hoạch ăn uống và luyện tập
                        String[] plans = fullText.split("(?i)\\bWorkout Plan\\b");
                        dietPlan = plans[0].trim(); // Phần trước từ khóa "Workout Plan" là kế hoạch ăn uống
                        workoutPlan = plans.length > 1 ? "Workout Plan " + plans[1].trim() : workoutPlan;
                    } else {
                        // Nếu không tìm thấy từ khóa, trả toàn bộ nội dung làm kế hoạch ăn uống
                        dietPlan = fullText.trim();
                    }

                    // Lưu kết quả vào database
                    ExerciseDietSuggestions dietSuggestions = new ExerciseDietSuggestions();
                    dietSuggestions.setGoal(existingGoal);
                    dietSuggestions.setDietPlan(dietPlan);
                    dietSuggestions.setWorkoutPlan(workoutPlan);

                    // Lưu vào cơ sở dữ liệu
                    return exerciseDietSuggestionsRepository.save(dietSuggestions);
                } else {
                    System.out.println("Text node is null.");
                }
            } else {
                System.out.println("Candidates not found in response.");
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to create diet plan", e);
        }
        return null;
    }

    //Tạo câu lệnh input cho API Google
    private String createInputTextForGoogle(UserDTO userDTO, Goal goal) {
        String userGoal = goal.getGoalType().toString();
        int age = userDTO.getProfileUserDTO().getAge();
        double weight = goal.getWeight();
        String activityLevel = goal.getActivityLevel().toString();
        double targetCalories = goal.getTargetCalories();

        return String.format(
                "Please create a 7-day personalized healthy diet plan for a %d-year-old individual weighing %.2f kg. " +
                        "This person has a daily caloric target of %.2f calories, is %s active, and is focused on the goal of %s. " +
                        "The diet plan should consist of 3 balanced meals per day, with healthy snacks included. " +
                        "Each meal should have the following macronutrient ratio: 40%% protein, 30%% carbohydrates, and 30%% fats. " +
                        "The meals should offer a variety of nutritious foods to ensure a well-rounded diet. " +
                        "Additionally, create a workout plan tailored to the individual's goals, whether muscle gain or fat loss. " +
                        "The workout plan should include strength training 3-4 times a week, focusing on compound exercises, " +
                        "and cardio 2-3 times a week. " +
                        "Adjust both the diet and workout plans based on the person’s progress towards their weight goals and overall health. " +
                        "The plan should be detailed, clear, and easy to follow. Ensure it stays within a 2000 character limit.",
                age, weight, targetCalories, activityLevel, userGoal
        );
    }


    // Phương thức tạo DietPlan cho các bữa ăn khác nhau từ API response
//    private ExerciseDietSuggestions createDietPlanForMeal(Goal goal, String apiResponse, String mealType, double totalCaloriesPerMeal) {
//
//        // Tính toán tỷ lệ dinh dưỡng dựa trên goalType
//        double[] nutritionRatios = calculateNutritionRatios(String.valueOf(goal.getGoalType()));
//        double proteinRatio = nutritionRatios[0];
//        double carbsRatio = nutritionRatios[1];
//        double fatRatio = nutritionRatios[2];
//
//        // Điều chỉnh lại lượng calo của các FoodItem nếu cần
//        //adjustFoodItemsCalories(foodItems, totalCaloriesPerMeal);
//
//        //2. Tính toán tổng calo từ các FoodItem (dựa trên API response)
//        double totalFoodItemCalories =
//                foodItems.stream()
//                .mapToDouble(FoodItem::getCalories)
//                .sum();
//
//
//        //3. Tạo Diet Plan
//        ExerciseDietSuggestions newDietPlan = new ExerciseDietSuggestions().builder()
//                .goal(goal)
//                .mealType(mealType)
//                .mealDescription("Plan for " + mealType)
//                .totalCalories(totalCaloriesPerMeal)
//                .protein_ratio(proteinRatio)
//                .carbs_ratio(carbsRatio)
//                .fat_ratio(fatRatio)
//                .foodItems(foodItems)
//                .createAt(LocalDateTime.now())
//                .build();
//
//        dietPlanRepository.save(newDietPlan);
//        //4. Lưu FoodItems vào cơ sở dữ liệu và liên kết với DietPlan
//        for (FoodItem foodItem : foodItems) {
//            foodItem.setDietPlan(newDietPlan);  // Gán DietPlan vào FoodItem
//            foodItemRepository.save(foodItem);
//        }
//        return newDietPlan;
//    }

    //Tính toán tỷ lệ dinh dưỡng dựa trên loại mục tiêu.(goalType)
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


    // Phương thức phân tích lượng calo từ chuỗi
    private double parseCalories(String caloriesStr) {
        try {
            return Double.parseDouble(caloriesStr.replaceAll("[^\\d.]", ""));  // Xóa ký tự không phải số và dấu chấm
        } catch (NumberFormatException e) {
            return 0.0; // Nếu không thể phân tích, trả về 0
        }
    }

    // Phương thức trích xuất giá trị dinh dưỡng (protein, carbs, fat) từ dòng mô tả
    private double extractNutrient(String line, String nutrient) {
        // Kiểm tra xem có từ khóa dinh dưỡng trong dòng không (ví dụ: "protein", "carbs", "fat")
        if (line.contains(nutrient)) {
            // Tìm giá trị dinh dưỡng từ mô tả
            String[] parts = line.split("\\s+");
            for (String part : parts) {
                if (part.contains(nutrient)) {
                    // Trích xuất giá trị số từ chuỗi (giả sử giá trị dinh dưỡng được biểu thị ngay sau từ khóa)
                    try {
                        return Double.parseDouble(part.replaceAll("[^\\d.]", ""));
                    } catch (NumberFormatException e) {
                        return 0.0;  // Nếu không thể phân tích giá trị, trả về 0
                    }
                }
            }
        }
        return 0.0;  // Nếu không tìm thấy giá trị dinh dưỡng, trả về 0
    }


    // Phương thức giúp phân tích calories từ chuỗi
//    private double parseCalories(String caloriesStr) {
//        try {
//            // Loại bỏ tất cả ký tự không phải là số và dấu chấm
//            return Double.parseDouble(caloriesStr.replaceAll("[^0-9.]", ""));
//        } catch (NumberFormatException e) {
//            return 0.0;  // Nếu không thể phân tích, trả về 0
//        }
//    }


    // Phương thức tính toán và điều chỉnh lượng calo của FoodItem
//    private void adjustFoodItemsCalories(List<FoodItem> foodItems, double targetCalories) {
//        double totalCalories = foodItems.stream().mapToDouble(FoodItem::getCalories).sum();
//        double remainingCalories = targetCalories - totalCalories;
//
//        if (remainingCalories > 0) {
//            // Nếu thiếu calo, thêm hoặc điều chỉnh FoodItem
//            for (FoodItem foodItem : foodItems) {
//                double foodItemCalories = foodItem.getCalories();
//                if (foodItemCalories <= remainingCalories) {
//                    //Tăng khẩu phần hoặc điều chỉnh lượng calo của món ăn hiện có
//                    foodItem.setCalories(foodItemCalories + remainingCalories);
//                    // Cập nhật lại số lượng khẩu phần (theo tỷ lệ)
//                    foodItem.setQuantity((int) (foodItem.getQuantity() * (foodItem.getCalories() / foodItemCalories)));
//                    break;
//                }
//            }
//        } else if (remainingCalories < 0) {
//            // Nếu thừa calo, giảm khẩu phần của một FoodItem
//            for (FoodItem foodItem : foodItems) {
//                double adjustedCalories = foodItem.getCalories() + remainingCalories;
//                if (adjustedCalories > 0) {
//                    foodItem.setCalories(adjustedCalories);
//                    foodItem.setQuantity((int) (foodItem.getQuantity() * (adjustedCalories / foodItem.getCalories())));  // Cập nhật khẩu phần
//                    break;
//                }
//            }
//        }
//    }

    //Phương thức lấy danh sách FoodItem cho bữa ăn dựa trên lượng calo
//    private List<FoodItem> getFoodItemsForMeal(double mealCalories, MealType mealType) {
//        List<FoodItem> foodItemList = foodItemRepository.findByDietPlan_MealType(mealType);
//        List<FoodItem> selectedFoodItems = new ArrayList<>();
//        double currentCalories = 0.0;
//
//        //Duyệt qua các foodItem và chọn foodItem sao cho tổng calo gần bằng mealCalories
//        for (FoodItem foodItem : foodItemList) {
//            if (currentCalories + foodItem.getCalories() <= mealCalories) {
//                selectedFoodItems.add(foodItem);  // Thêm foodItem vào danh sách
//                currentCalories += foodItem.getCalories();  // Cập nhật tổng calo đã chọn
//            }
//            if (currentCalories >= mealCalories) {
//                break; //Dừng khi đã đủ tổng lượng calo cho bữa ăn và break;
//            }
//        }
//        // Điều chỉnh lại lượng calo của các FoodItem nếu cần
//        adjustFoodItemsCalories(selectedFoodItems, mealCalories);
//
//        return selectedFoodItems;
//    }

    //Handle edit a dietPlan
//    public DietPlan updateDietPlan(int id, UpdateDietPlanDTO dietPlanDTO) {
//        DietPlan existingDiet = dietPlanRepository.findById(id).get();
//        if (existingDiet == null) {
//            throw new RuntimeException("Diet plan not found");
//        }
//        existingDiet.setMealType(dietPlanDTO.getMealType());
//        existingDiet.setMealDescription(dietPlanDTO.getMealDescription());
//        existingDiet.setTotalCalories(dietPlanDTO.getTotalCalories());
//        existingDiet.setProtein_ratio(dietPlanDTO.getProtein_ratio());
//        existingDiet.setCarbs_ratio(dietPlanDTO.getCarbs_ratio());
//        existingDiet.setFat_ratio(dietPlanDTO.getFat_ratio());
//        existingDiet.setUpdateAt(LocalDateTime.now());
//
//        return dietPlanRepository.save(existingDiet);
//    }

    //Handle delete DietPlan
    public ExerciseDietSuggestions deleteDietPlan(int id) {
        ExerciseDietSuggestions existingDiet = exerciseDietSuggestionsRepository.findById(id).get();
        if (existingDiet == null) {
            throw new RuntimeException("Diet plan not found");
        }
        exerciseDietSuggestionsRepository.delete(existingDiet);
        return existingDiet;
    }

}
