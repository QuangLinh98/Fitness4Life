package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Gender;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CalculationService {

    //Handle get last weight from user was updated
    public Double calculateTdee(double weight, UserDTO userDTO, String activityLevel) {

        int height = userDTO.getProfileUserDTO().getHeightValue();
        int age = userDTO.getProfileUserDTO().getAge();
        Gender gender = userDTO.getGender();

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

    public double calculateBMI(double weight, UserDTO userDTO) {
        double heightInMeters = userDTO.getProfileUserDTO().getHeightValue() / 100.0;
        return weight / (heightInMeters * heightInMeters);
    }

    //Phương thức tính toán tỷ lệ % hoàn thành mục tiêu của user
    public double calulateGoalProgress(Goal goal) {
        double progress = 0;

        //Tính toán tỷ lệ tiến độ dựa trên các chỉ số mục tiêu
        switch (goal.getGoalType()) {
            case WEIGHT_LOSS:
                if (goal.getTargetValue() != null && goal.getCurrentValue() != null) {
                    progress = ((goal.getWeight() - goal.getCurrentValue()) / (goal.getWeight() - goal.getTargetValue())) * 100;
                    System.out.println("Progress weight loss completed %: " + progress);
                }
                break;
            case WEIGHT_GAIN:
                if (goal.getTargetValue() != null && goal.getCurrentValue() != null) {
                    progress = ((goal.getCurrentValue() - goal.getWeight()) / (goal.getTargetValue() - goal.getWeight())) * 100;
                    System.out.println("Progress weight gain completed %: " + progress);
                }
                break;
            case MUSCLE_GAIN:
                if (goal.getTargetValue() != null && goal.getCurrentValue() != null) {
                    progress = (goal.getCurrentValue() / goal.getTargetValue()) * 100;
                    System.out.println("Progress muscle gain completed %: " + progress);
                }
                break;
            case FAT_LOSS:
                if (goal.getTargetValue() != null && goal.getCurrentValue() != null) {
                    progress = ((goal.getTargetValue() - goal.getCurrentValue()) / (goal.getTargetValue())) * 100;
                    System.out.println("Progress fat loss completed %: " + progress);
                }
                break;
            default:
                throw new IllegalArgumentException("Invalid goal type.");
        }
        return progress;
    }
}
