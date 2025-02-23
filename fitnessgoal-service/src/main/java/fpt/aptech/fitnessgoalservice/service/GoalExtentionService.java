package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.GoalExtension;
import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import fpt.aptech.fitnessgoalservice.notification.NotifyService;
import fpt.aptech.fitnessgoalservice.repository.GoalExtentionRepository;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GoalExtentionService {
    private final GoalExtentionRepository extentionRepository;
    private final GoalRepository goalRepository;
    private final NotifyService notifyService;
    private final UserEurekaClient userEurekaClient;
    private final CalculationService calculationService;

    //Phương thức quản lý gia hạn mục tiêu
    public GoalExtension extendGoalDeadline(int goalId, boolean userResponse) {
        try {
            Goal existingGoal = goalRepository.findById(goalId).orElseThrow(() -> new RuntimeException("Goal not found"));

            // Tính số ngày còn lại cho đến ngày kết thúc mục tiêu
            long daysRemaining = LocalDate.now().until(existingGoal.getEndDate(), ChronoUnit.DAYS);
            System.out.println("Days remaining : " + daysRemaining);
            //Tính toán tiến độ % hoàn thành mục tiêu
            double progress = calculationService.calulateGoalProgress(existingGoal);  // Phần trăm đã hoàn thành

            //Nếu tiến độ < 100% , gia hạn thời gian cho  mục tiêu
            if (progress < 100) {
                if (userResponse) {
                    //Tính toán tỷ lệ gia hạn thời gian dựa trên mục tiêu
                    double extensionRadio = (100 - progress) / 100;
                    System.out.println("Extension Radio : " + extensionRadio);

                    // Tính số ngày bổ sung dựa trên số ngày còn lại
                    long additionalDays;
                    if (daysRemaining > 0) {
                        double calulatedDays = daysRemaining * extensionRadio;
                        System.out.println("Calculated Days : " + calulatedDays);
                        additionalDays = Math.max((long) calulatedDays, 7); //Gia hạn tối thiểu 7 ngày
                        System.out.println("additional Days 1: " + additionalDays);
                    } else {
                        //Nếu hết hạn , gia hạn mặc định dựa trên tỷ lệ %
                        additionalDays = Math.max((long) (14 * extensionRadio), 7); //Gia hạn tối thiểu 7 ngày
                        System.out.println("additional Days  : " + additionalDays);
                    }

                    //Nếu tiến độ của mục tiêu quá thấp (vd: < 30%) , có thể gian hạn thêm 50% thời gian
                    if (progress < 30) {
                        additionalDays *= 1.5;   //Gian hạn thêm 50% thời gian
                    }

                    // Tính ngày kết thúc mới bằng cách cộng các ngày bổ sung
                    LocalDate newEndDate = existingGoal.getEndDate().plusDays(additionalDays);
                    GoalExtension goalExtension = GoalExtension.builder()
                            .goal(existingGoal)
                            .originalEndTime(existingGoal.getEndDate())
                            .newEndTime(LocalDate.from(newEndDate))
                            .userResponse(true)
                            .createdAt(LocalDateTime.now())
                            .build();
                    extentionRepository.save(goalExtension);
                    // Cập nhật ngày kết thúc mới cho mục tiêu , nếu user phản hồi đồng ý gia hạn mục tiêu

                    existingGoal.setEndDate(newEndDate);
                    goalRepository.save(existingGoal);
                    return goalExtension;
                } else {
                    existingGoal.setGoalStatus(GoalStatus.FAILED);
                    goalRepository.save(existingGoal);
                    return null;
                }
            } else {
                throw new IllegalArgumentException("Goal is already completed, no need for extension.");
            }
        } catch (Exception ex) {
            throw new RuntimeException("An error occurred while extending goal deadline: " + ex.getMessage());
        }
    }

    //Lấy danh sách lịch sử gia hạn
    public List<GoalExtension> getGoalExtensions(int goalId) {
        List<GoalExtension> goalExtensions = extentionRepository.findByGoalId(goalId);
        if (goalExtensions.isEmpty()) {
            throw new RuntimeException("No extensions found for the given goal.");
        }
        return goalExtensions;
    }
}
