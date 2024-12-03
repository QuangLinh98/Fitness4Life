package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.ProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import fpt.aptech.fitnessgoalservice.models.GoalType;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import fpt.aptech.fitnessgoalservice.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProgressService {
    private final ProgressRepository progressRepository;
    private final GoalRepository goalRepository;
    private final UserEurekaClient userEurekaClient;

    //Handle get all progress data
    public List<Progress> getAllProgress() {
        return progressRepository.findAll();
    }

    //Handle get one progress by id
    public Progress getProgressById(int id) {
        return progressRepository.findById(id).get();
    }

    //Handle add a progress
    public Progress createProgress(ProgressDTO progressDTO) {
        UserDTO existingUser = userEurekaClient.getUserById(progressDTO.getUserId());
        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }
        Goal existingGoal = goalRepository.findById(progressDTO.getGoal()).orElseThrow(() -> new RuntimeException("Goal not found"));
        //Kiểm tra trạng thái của Goal nếu là COMPLETED or FAILED thì không cho user nhập Progress
        if (existingGoal.getGoalStatus() == GoalStatus.COMPLETED || existingGoal.getGoalStatus() == GoalStatus.FAILED) {
            throw new RuntimeException("Cannot add progress. Goal is already " + existingGoal.getGoalStatus());
        }
        Progress newProgress = Progress.builder()
                .userId(progressDTO.getUserId())
                .goal(existingGoal)
                .fullName(existingGoal.getFullName())
                .trackingDate(progressDTO.getTrackingDate())
                .metricName(progressDTO.getMetricName())
                .value(progressDTO.getValue())
                .weight(progressDTO.getWeight())
                .caloriesConsumed(progressDTO.getCaloriesConsumed())
                .createdAt(LocalDateTime.now())
                .build();

        //So sánh lương caloriesConsumed với targetCalories trong bảng Goal và hiển thị message
        double targetCalories = existingGoal.getTargetCalories();
        double caloriesConsumed = progressDTO.getCaloriesConsumed();
        if (caloriesConsumed > targetCalories) {
            newProgress.setMessage("Ban đa vuot qua " + (caloriesConsumed - targetCalories) + " calo.Hay giam luong calo nap vao.");
        } else if (caloriesConsumed < targetCalories) {
            newProgress.setMessage("Ban can bo sung them " + (targetCalories - caloriesConsumed) + " calo đe đat muc tieu.");
        } else {
            newProgress.setMessage("Ban da tieu thu dung luong calo de dat muc tieu.");
        }

        //Cập nhật giá trị currentValue trong Goal dựa vào metricName
        switch (progressDTO.getMetricName().name().toUpperCase()) {
            case "WEIGHT":
                if (existingGoal.getGoalType() == GoalType.WEIGHT_LOSS || existingGoal.getGoalType() == GoalType.WEIGHT_GAIN) {
                    existingGoal.setCurrentValue(progressDTO.getValue());
                }
                break;
            case "BODY_FAT":
                if (existingGoal.getGoalType() == GoalType.FAT_LOSS) {
                    existingGoal.setCurrentValue(progressDTO.getValue());
                }
                break;
            case "MUSCLEMASS":
                if (existingGoal.getGoalType() == GoalType.MUSCLE_GAIN) {
                    existingGoal.setCurrentValue(progressDTO.getValue());
                }
                break;
            default:
                //Duy trì cân nặng thì không cần cập nhật currentValue
                break;
        }
        //Kiểm tra trạng thái của goal nếu currentValue >= targetValue thì hoàn thành mục tiêu và hiển thị message
        if (existingGoal.getCurrentValue() >= existingGoal.getTargetValue()) {
            existingGoal.setGoalStatus(GoalStatus.COMPLETED);
            if (existingGoal.getGoalStatus() == GoalStatus.COMPLETED) {
                newProgress.setMessage(newProgress.getMessage() + " Muc tieu cua ban da hoan thanh.Xin chuc mung.");
            }
        }
        // Lưu lại cập nhật vào bảng Goal
        goalRepository.save(existingGoal);
        return progressRepository.save(newProgress);
    }

    //Handle update a progress
    public Progress updateProgress(int id, UpdateProgressDTO updateProgressDTO) {
        Progress existingProgress = getProgressById(id);
        Goal goal = goalRepository.findById(updateProgressDTO.getGoalId()).orElseThrow(() -> new RuntimeException("Goal not found"));
        //Kiểm tra trạng thái của Goal nếu là COMPLETED or FAILED thì không cho user nhập Progress
        if (goal.getGoalStatus() == GoalStatus.COMPLETED || goal.getGoalStatus() == GoalStatus.FAILED) {
            throw new RuntimeException("Cannot add progress. Goal is already " + goal.getGoalStatus());
        }
        if (existingProgress != null) {
            existingProgress.setTrackingDate(updateProgressDTO.getTrackingDate());
            existingProgress.setMetricName(updateProgressDTO.getMetricName());
            existingProgress.setValue(updateProgressDTO.getValue());
            existingProgress.setWeight(updateProgressDTO.getWeight());
            existingProgress.setCaloriesConsumed(updateProgressDTO.getCaloriesConsumed());
            existingProgress.setUpdatedAt(LocalDateTime.now());

            //So sánh lương caloriesConsumed với targetCalories trong bảng Goal và hiển thị message
            double targetCalories = goal.getTargetCalories();
            double caloriesConsumed = updateProgressDTO.getCaloriesConsumed();
            if (caloriesConsumed > targetCalories) {
                existingProgress.setMessage("Ban đa vuot qua " + (caloriesConsumed - targetCalories) + " calo.Hay giam luong calo nap vao.");
            } else if (caloriesConsumed < targetCalories) {
                existingProgress.setMessage("Ban can bo sung them " + (targetCalories - caloriesConsumed) + " calo đe đat muc tieu.");
            } else {
                existingProgress.setMessage("Ban da tieu thu dung luong calo de dat muc tieu.");
            }

            //Cập nhật giá trị currentValue trong Goal dựa vào metricName
            switch (updateProgressDTO.getMetricName().name().toUpperCase()) {
                case "WEIGHT":
                    if (goal.getGoalType() == GoalType.WEIGHT_LOSS || goal.getGoalType() == GoalType.WEIGHT_GAIN) {
                        goal.setCurrentValue(updateProgressDTO.getValue());
                    }
                    break;
                case "BODY_FAT":
                    if (goal.getGoalType() == GoalType.FAT_LOSS) {
                        goal.setCurrentValue(updateProgressDTO.getValue());
                    }
                    break;
                case "MUSCLEMASS":
                    if (goal.getGoalType() == GoalType.MUSCLE_GAIN) {
                        goal.setCurrentValue(updateProgressDTO.getValue());
                    }
                    break;
                default:
                    //Duy trì cân nặng thì không cần cập nhật currentValue
                    break;
            }
            //Kiểm tra trạng thái của goal nếu currentValue >= targetValue thì hoàn thành mục tiêu và hiển thị message
            if (goal.getCurrentValue() >= goal.getTargetValue()) {
                goal.setGoalStatus(GoalStatus.COMPLETED);
                if (goal.getGoalStatus() == GoalStatus.COMPLETED) {
                    existingProgress.setMessage(existingProgress.getMessage() + " Muc tieu cua ban da hoan thanh.Xin chuc mung.");
                }
            }
            // Lưu lại cập nhật vào bảng Goal
            goalRepository.save(goal);
            return progressRepository.save(existingProgress);
        }
        throw new RuntimeException("Progress not found");
    }

    //Handle delete progress
    public void deleteProgress(int id) {
        Progress existingProgress = getProgressById(id);
        if (existingProgress != null) {
            progressRepository.delete(existingProgress);
        }
    }

    //Xử lý phân tích tiến trình tập luyện của user
    public String analyzeProgress(long userId) {
        List<Progress> progressList = progressRepository.findByUserId(userId);
        // Logic phân tích: Xu hướng cân nặng tăng hay giảm
        double totalCalories = progressList.stream().mapToDouble(Progress::getCaloriesConsumed).sum();
        return "Tổng lượng calo cần tiêu thụ trong tuần : " + totalCalories;
    }
}
