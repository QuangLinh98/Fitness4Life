package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.ChangeGoalStatusDTO;
import fpt.aptech.fitnessgoalservice.dtos.GoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateGoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import fpt.aptech.fitnessgoalservice.models.GoalType;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final CalculationService calculationService;
    private final DietPlanService dietPlanService;
    private final UserEurekaClient userEurekaClient;

    //Handle get all data
    public List<Goal> getAllGoals() {
        return goalRepository.findAll();
    }

    //Handle get one goal by id
    public Goal getGoalById(int id) {
        return goalRepository.findById(id).get();
    }

    //Handle create Goal
    public Goal createGoal(GoalDTO goalDTO) {
        UserDTO existingUser = userEurekaClient.getUserById(goalDTO.getUserId());
        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }
        // Lấy thông tin cân nặng và giá trị hiện tại
        Double weight = goalDTO.getWeight();
        Double currentValue = goalDTO.getCurrentValue();

        // Chỉ xử lý đồng bộ khi mục tiêu là WEIGHT_LOSS hoặc WEIGHT_GAIN
        if (goalDTO.getGoalType() == GoalType.WEIGHT_LOSS || goalDTO.getGoalType() == GoalType.WEIGHT_GAIN) {
            if (weight == null && currentValue == null) {
                throw new RuntimeException("For weight-related goals, at least one of weight or currentValue must be provided.");
            }

            // Nếu chỉ có currentValue
            if (weight == null) {
                weight = currentValue; // Gán weight bằng currentValue
            }

            // Nếu chỉ có weight
            if (currentValue == null) {
                currentValue = weight; // Gán currentValue bằng weight
            }

            // Kiểm tra tính hợp lệ
            if (weight <= 0 || currentValue <= 0) {
                throw new RuntimeException("Weight and currentValue must be greater than 0 for weight-related goals.");
            }
        }
        // Lấy giá trị activityLevel(hệ số hoạt động)
        String activityLevel = goalDTO.getActivityLevel().name();
        //Tính TDEE
        double tdee = calculationService.calculateTdee(weight, existingUser, activityLevel);

        //Tính calo mục tiêu
        double targetCalories = goalDTO.getGoalType().calculateTargetCalories(tdee);
        Goal goal = Goal.builder()
                .userId(goalDTO.getUserId())
                .fullName(existingUser.getFullName())
                .goalType(goalDTO.getGoalType())
                .targetValue(goalDTO.getTargetValue())
                .currentValue(goalDTO.getCurrentValue())
                .weight(weight)
                .startDate(goalDTO.getStartDate())
                .endDate(goalDTO.getEndDate())
                .goalStatus(GoalStatus.PLANNING)
                .activityLevel(goalDTO.getActivityLevel())
                .targetCalories(targetCalories)
                .createdAt(LocalDateTime.now())
                .build();
        Goal saveGoal = goalRepository.save(goal);
        //Sau khi tạo goal hệ thống sẽ gợi ý chế độ ăn bằng cách gọi lại hàm
        dietPlanService.createDietPlanForUser(saveGoal);
        return saveGoal;
    }

    //Handle update Goal
    public Goal updateGoal(int id, UpdateGoalDTO goalDTO) {
        Goal existingGoal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        UserDTO existingUser = userEurekaClient.getUserById(goalDTO.getUserId());
        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }
        // Nếu mục tiêu đã hoàn thành, không thể cập nhật
        if (existingGoal.getGoalStatus() == GoalStatus.COMPLETED) {
            throw new RuntimeException("Goal already completed");
        }

        // Kiểm tra các giá trị mục tiêu (nếu cần thiết, có thể thêm các kiểm tra tính hợp lệ khác)
        Double weight = goalDTO.getWeight();
        Double currentValue = goalDTO.getCurrentValue();
        if ((goalDTO.getGoalType() == GoalType.WEIGHT_LOSS || goalDTO.getGoalType() == GoalType.WEIGHT_GAIN) &&
                (weight == null && currentValue == null)) {
            throw new RuntimeException("For weight-related goals, at least one of weight or currentValue must be provided.");
        }

        // Nếu chỉ có một trong hai giá trị (weight hoặc currentValue), gán giá trị còn lại
        if (weight == null) {
            weight = currentValue;
        }
        if (currentValue == null) {
            currentValue = weight;
        }

        // Kiểm tra hợp lệ (cân nặng và giá trị mục tiêu phải > 0)
        if (weight <= 0 || currentValue <= 0) {
            throw new RuntimeException("Weight and currentValue must be greater than 0 for weight-related goals.");
        }

        // Cập nhật các thuộc tính của goal từ goalDTO
        existingGoal.setGoalType(goalDTO.getGoalType());
        existingGoal.setTargetValue(goalDTO.getTargetValue());
        existingGoal.setCurrentValue(goalDTO.getCurrentValue());
        existingGoal.setWeight(weight);
        existingGoal.setActivityLevel(goalDTO.getActivityLevel());

        // Nếu trạng thái của goal đang trong tiến trình hoặc thất bại, cho phép cập nhật ngày bắt đầu và ngày kết thúc
        if (existingGoal.getGoalStatus() == GoalStatus.IN_PROGRESS || existingGoal.getGoalStatus() == GoalStatus.FAILED) {
            existingGoal.setStartDate(goalDTO.getStartDate());
            existingGoal.setEndDate(goalDTO.getEndDate());
        }

        // Tính toán lại TDEE dựa trên thông tin mới
        double tdee = calculationService.calculateTdee(weight, existingUser, goalDTO.getActivityLevel().name());

        // Tính lại calo mục tiêu
        double targetCalories = goalDTO.getGoalType().calculateTargetCalories(tdee);

        // Cập nhật lại targetCalories trong mục tiêu
        existingGoal.setTargetCalories(targetCalories);

        // Lưu mục tiêu đã được cập nhật vào cơ sở dữ liệu
        return goalRepository.save(existingGoal);
    }


    //Handle update goal status
    public Goal changeGoalStatusById(int id, ChangeGoalStatusDTO goalStatusDTO) {
        Goal existingGoal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        // Kiểm tra nếu mục tiêu đã hết hạn
        if (existingGoal.getEndDate().isBefore(LocalDate.now())) {
            if (existingGoal.getGoalStatus() != GoalStatus.COMPLETED) {
                existingGoal.setGoalStatus(GoalStatus.FAILED);
                goalRepository.save(existingGoal);
                throw new RuntimeException("Goal has expired and is set to FAILED.");
            }
        }

        // Lấy trạng thái hiện tại và trạng thái mới
        GoalStatus currentStatus = existingGoal.getGoalStatus();
        GoalStatus newStatus = GoalStatus.valueOf(goalStatusDTO.getGoalStatus());

        // Kiểm tra trạng thái hiện tại
        if (currentStatus == GoalStatus.COMPLETED || currentStatus == GoalStatus.FAILED) {
            throw new RuntimeException("Cannot change status. Current goal is already " + currentStatus);
        }

        // Kiểm tra logic chuyển đổi trạng thái
        if (currentStatus == GoalStatus.IN_PROGRESS && newStatus == GoalStatus.PLANNING) {
            throw new RuntimeException("Cannot revert goal from IN_PROGRESS to PLANNING");
        }
        // Cập nhật trạng thái mới
        existingGoal.setGoalStatus(newStatus);
        goalRepository.save(existingGoal);
        return existingGoal;
    }

    //Handle delete Goal
    public void deleteGoal(int id) {
        Goal goal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        goalRepository.delete(goal);
    }
}
