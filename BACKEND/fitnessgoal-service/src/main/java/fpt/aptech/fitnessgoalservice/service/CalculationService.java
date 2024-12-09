package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Gender;
import fpt.aptech.fitnessgoalservice.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CalculationService {
    private final ProgressRepository progressRepository;
    //private final GoalService goalService;
    private final UserEurekaClient userEurekaClient;

    //Handle get last weight from user was updated
    public Double calculateTdee(double weight,UserDTO userDTO,String activityLevel) {

        //Lấy cân nặng mới nhất
//        Progress weightProgress = progressRepository.findTopByUserIdAndMetricNameOrderByTrackingDateDesc(userId, "weight")
//                .orElseThrow(() -> new RuntimeException("Weight data not found"));
//
//        Double weight = weightProgress.getWeight();
        int height = userDTO.getProfileUserDTO().getHeightValue();
        int age = userDTO.getProfileUserDTO().getAge();
        Gender gender = userDTO.getGender();

         //Lấy thông tin goal
//        Goal goal = goalService.getGoalById(goalId);
//        if (goal == null) {
//            throw new RuntimeException("Goal not found");
//        }
//        String activityLevel = goal.getActivityLevel().name();

        //Tính BMR
        Double bmr = 0.0;
        if (gender == Gender.MALE) {
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
        } else if (gender == Gender.FEMALE) {
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
        }

        //Hệ số hoạt đông
        Double multiplier;
        switch (activityLevel.toUpperCase()) {
            case "LIGHTLY_ACTIVE":
                multiplier = 1.375;
                break;
            case "MODERATELY_ACTIVE":
                multiplier = 1.55;
                break;
            case "VERY_ACTIVE":
                multiplier = 1.725;
                break;
            case "EXTREMELY_ACTIVE":
                multiplier = 1.9;
                break;
            default:  //SEDENTARY
                multiplier = 1.2;
                break;
        }
        System.out.println("Activity Level: " + activityLevel);

        //Tính TDEE
        return bmr * multiplier;
    }


}
