package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.ProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.*;
import fpt.aptech.fitnessgoalservice.notification.NotifyService;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import fpt.aptech.fitnessgoalservice.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class ProgressService {
    private final ProgressRepository progressRepository;
    private final GoalRepository goalRepository;
    private final UserEurekaClient userEurekaClient;
    private final NotifyService notifyService;
    private final UserPointService pointService;

    //Handle get all progress data
    public List<Progress> getAllProgress() {
        System.out.println("request nhận được từ ");
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
            newProgress.setMessage("You have passed " + (caloriesConsumed - targetCalories) + " calories.Or reduce calorie intake.");
        } else if (caloriesConsumed < targetCalories) {
            newProgress.setMessage("You need to add more " + (targetCalories - caloriesConsumed) + " calories to reach daily calorie goal.");
        } else {
            newProgress.setMessage("You have consumed the calories to reach your daily calorie goal.");
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
        //Gọi phương thức cập nhật Goal Status
        int pointsToAdd = checkAndUpdateGoalStatus(existingGoal, newProgress);

        // Lưu lại cập nhật vào bảng Goal
        goalRepository.save(existingGoal);

        // Gửi thông báo nếu có điểm được cộng qua notifi-service
        if (pointsToAdd > 0) {
            String resultMessage = "Ban da hoan thanh mot moc quan trong cho muc tieu " + existingGoal.getGoalType() + ". Ban đuoc cong " + pointsToAdd + " điem.";
            notifyService.sendPointNotification(existingUser, existingGoal, resultMessage, pointsToAdd);
        }

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
            //Gọi phương thức cập nhật Goal Status
            checkAndUpdateGoalStatus(goal, existingProgress);

            // Lưu lại cập nhật vào bảng Goal
            goalRepository.save(goal);
            return progressRepository.save(existingProgress);
        }
        throw new RuntimeException("Progress not found");
    }

    //Phương thức xử lý kiểm tra và cập nhật goal status
    private int checkAndUpdateGoalStatus(Goal goal, Progress progress) {
        double currentValue = goal.getCurrentValue();
        double targetValue = goal.getTargetValue();
        int pointsToAdd = 0; // Biến lưu điểm thưởng

        // Kiểm tra nếu đạt 50% mục tiêu
        boolean isHalfCompleted = progressRepository.existsByGoalIdAndMessageContaining(goal.getId(), "đạt 50%");
        if (!isHalfCompleted && goal.getGoalStatus().equals(GoalStatus.IN_PROGRESS) && currentValue >= targetValue * 0.5) {
            //Thưởng điểm khi đạt 50% mục tiêu
            pointsToAdd += 50;
        }

        if (goal.getGoalType() == GoalType.MUSCLE_GAIN || goal.getGoalType() == GoalType.WEIGHT_GAIN) {
            if (goal.getCurrentValue() >= goal.getTargetValue()) {
                // Check if currentValue exceeds targetValue significantly
                if (goal.getCurrentValue() - goal.getTargetCalories() > 4) {
                    progress.setMessage(progress.getMessage() + " Luu y: Ban da vuot qua muc tieu qua nhieu (" + (goal.getCurrentValue() - goal.getTargetCalories()) + "). Hay dieu chinh lai ke hoach.");
                }
                goal.setGoalStatus(GoalStatus.COMPLETED);
                if (goal.getGoalStatus() == GoalStatus.COMPLETED) {
                    progress.setMessage(progress.getMessage() + " Muc tieu cua ban da hoan thanh. Xin chuc mung.");
                    //Cộng điểm nếu mục tiêu hoàn thành
                    pointsToAdd += 500;
                }
            }
        }
        if (goal.getGoalType() == GoalType.WEIGHT_LOSS || goal.getGoalType() == GoalType.FAT_LOSS) {
            if (goal.getCurrentValue() <= goal.getTargetValue()) {
                // Check if targetValue significantly exceeds currentValue
                if (goal.getTargetValue() - goal.getCurrentValue() > 4) {
                    progress.setMessage(progress.getMessage() + " Luu y: Ban da giam qua nhieu (hơn " + (goal.getTargetValue() - goal.getCurrentValue()) + "). Hay xem xet lai ke hoach.");
                }
                goal.setGoalStatus(GoalStatus.COMPLETED);
                if (goal.getGoalStatus() == GoalStatus.COMPLETED) {
                    progress.setMessage(progress.getMessage() + " Muc tieu cua ban da hoan thanh. Xin chuc mung.");
                    // Thưởng điểm khi hoàn thành mục tiêu
                    pointsToAdd += 500;
                }
            }
        }

        // Thực hiện cộng điểm nếu có
        if (pointsToAdd > 0) {
            pointService.addPoint(goal.getUserId(), pointsToAdd);
        }
        return pointsToAdd;
    }

    //Handle delete progress
    public void deleteProgress(int id) {
        Progress existingProgress = getProgressById(id);
        if (existingProgress != null) {
            progressRepository.delete(existingProgress);
        }
    }

    //Lấy chỉ số sức khỏe trong khoảng thời gian khi người dùng thực hiện so sánh các chỉ số sức khỏe so với ban đầu
    public List<Progress> getProgressData(int userId, int goalId, LocalDate startDate, LocalDate endDate) {
        List<Progress> progressList = progressRepository.findByUserIdAndGoalIdAndTrackingDateBetween(userId, goalId, startDate, endDate);
        return progressList;
    }

    // Tính sự thay đổi về cân nặng, mỡ cơ thể, hoặc khối cơ
    public double calculateChangeOverPeriod(List<Progress> progressList,
                                            MetricName metricName,
                                            double targetValue) {
        Double endValue = null;
        // Lọc ra các progress có metricName tương ứng và tính toán giá trị bắt đầu và kết thúc
        for (Progress progress : progressList) {
            if (progress.getMetricName() == metricName) {
                endValue = progress.getValueByMetric();  // Lấy giá trị cuối cùng
            }
        }

        // Nếu không có giá trị hợp lệ cho metric, trả về 0
        if (endValue == null) {
            return 0.0;  // Không có sự thay đổi nếu không có dữ liệu
        }
        System.out.println("Change value " + (endValue - targetValue));
        // So sánh endValue với targetValue và tính sự thay đổi
        return endValue - targetValue;
    }

    //Phân tích các chỉ số tiến trình tập luyện trong khoảng thời gian và gửi thông báo
    public String analyzeProgress(int userId, int goalId, LocalDate startDate, LocalDate endDate) {
        // lấy dữ liệu cân nặng , mỡ cơ thể , cơ , calo tiêu thụ
        List<Progress> progressList = getProgressData(userId, goalId, startDate, endDate);
        if (progressList.isEmpty()) {
            return "There is no data for this time period.";
        }

        //Lấy mục tiêu của người dùng (targetValue)
        List<Goal> goals = goalRepository.findGoalByUserId(userId);
        if (goals == null) {
            throw new RuntimeException("No goal found for user");
        }
        StringBuilder messageBuilder = new StringBuilder();

        // Phân tích tiến trình cho từng mục tiêu của người dùng
        for (Goal goal : goals) {
            // Tính sự thay đổi và so sánh với mục tiêu
            double weightChange = calculateChangeOverPeriod(progressList, MetricName.WEIGHT, goal.getTargetValue());
            double bodyFatChange = calculateChangeOverPeriod(progressList, MetricName.BODY_FAT, goal.getTargetValue());
            double muscleMassChange = calculateChangeOverPeriod(progressList, MetricName.MUSCLEMASS, goal.getTargetValue());
            System.out.println("Weight change: " + weightChange);
            System.out.println("bodyFat change: " + bodyFatChange);
            System.out.println("muscleMass change: " + muscleMassChange);
            // So sánh và in thông báo theo metricName
            String message = "";

            UserDTO existingUser = userEurekaClient.getUserById(userId);
            // Gửi thông báo chỉ khi change có sự thay đổi
            if (weightChange != 0) {
                message = compareWithGoal(weightChange, goal);
                notifyService.sendAnalyticsNotification(existingUser, goal, message);
            }
            if (bodyFatChange != 0) {
                message = compareWithGoal(bodyFatChange, goal);
                notifyService.sendAnalyticsNotification(existingUser, goal, message);
            }
            if (muscleMassChange != 0) {
                message = compareWithGoal(muscleMassChange, goal);
                notifyService.sendAnalyticsNotification(existingUser, goal, message);
            }
            return message;
        }
        // Trả về tất cả các thông báo
        return null;
    }

    //So sánh với mục tiêu của người dùng
    public String compareWithGoal(double change, Goal goal) {
        String result = "";

        // Kiểm tra mục tiêu giảm cân (WEIGHT_LOSS)
        if (goal.getGoalType() == GoalType.WEIGHT_LOSS) {
            if (change > 0) {
                result = "Ban can giam them " + Math.abs(change) + "kg,de dat muc tieu giam can ve " + goal.getTargetValue() + "kg";
            } else {
                result = "Ban da giam " + change + "kg de dat muc tieu giam can.";
            }
        }

        // Kiểm tra mục tiêu tăng cân (WEIGHT_GAIN)
        else if (goal.getGoalType() == GoalType.WEIGHT_GAIN) {
            if (change > 0) {
                result = "Ban da tang " + change + "kg, dat muc tieu tang can.";
            } else if (change < 0) {
                result = "Ban can tang them " + Math.abs(change) + "kg de dat muc tieu tang can len " + goal.getTargetValue() + "kg";
            }
        }

        // Kiểm tra mục tiêu tăng cơ (MUSCLE_GAIN)
        else if (goal.getGoalType() == GoalType.MUSCLE_GAIN) {
            if (change < 0) {
                result = "Ban can tang them " + Math.abs(change) + "% cơ, dat muc tieu tang co len " + goal.getTargetValue() + "% co";
            } else if (change > 0) {
                result = "Ban da mat " + change + "% cơ, can tang them % cơ de dat muc tieu tang co.";
            } else {
                result = "Ban da dat muc tieu tang co.";
            }
        }

        // Kiểm tra mục tiêu giảm mỡ (FAT_LOSS)
        else if (goal.getGoalType() == GoalType.FAT_LOSS) {
            if (change < 0) {
                result = "Ban da giam " + Math.abs(change) + "% mo, dat muc tieu giam mo.";
            } else if (change > 0) {
                result = "Ban can giam them " + change + "% mo de dat muc tieu giam mo.";
            }
        }
        // Nếu không khớp với bất kỳ mục tiêu nào
        else {
            result = "Muc tieu khong hop le hoac khong co thay doi nao.";
        }

        return result;
    }

    public List<Progress> getProgressByGoalId(int goalId) {
        return progressRepository.findByGoalId(goalId);
    }
}