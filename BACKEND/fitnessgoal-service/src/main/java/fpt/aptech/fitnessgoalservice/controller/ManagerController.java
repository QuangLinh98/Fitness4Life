package fpt.aptech.fitnessgoalservice.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.fitnessgoalservice.dtos.*;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.kafka.NotifyProducer;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.dtos.NotifyDTO;
import fpt.aptech.fitnessgoalservice.models.GoalExtension;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.notification.NotifyService;
import fpt.aptech.fitnessgoalservice.service.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.apache.http.HttpStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/goal/")
@RequiredArgsConstructor
public class ManagerController {
    private final GoalService goalService;
    private final GoalExtentionService goalExtensionService;
    private final NotifyProducer notifyProducer;
    private final ProgressService progressService;
    private final ExerciseDietSuggestionsService dietPlanService;
    private final UserEurekaClient userEurekaClient;
    private final NotifyService notifyService;
    private final HttpServletRequest request;
    private final ObjectMapper objectMapper;
    private final UserPointService userPointService;

    @PostMapping("add")
    public ResponseEntity<?> AddGoal(@RequestBody GoalDTO goalDTO) {
        try {
            Goal newGoal = goalService.createGoal(goalDTO);
            //Test user
            UserDTO existingUser = userEurekaClient.getUserById(goalDTO.getUserId());

            //Send notification to user . When user add a goal successfully
            try {
                NotifyDTO notifyDTO = new NotifyDTO();
                notifyDTO.setItemId(newGoal.getId());
                notifyDTO.setUserId(goalDTO.getUserId());
                notifyService.sendCreatedNotification(existingUser, notifyDTO, goalDTO);
            }catch (Exception e) {
                System.out.println(e.getMessage());
            }

            return ResponseEntity.status(201).body(ApiResponse.created(newGoal, "Create goal successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PutMapping("update/{id}")
    public ResponseEntity<?> UpdateGoal(@Valid @PathVariable int id, @RequestBody UpdateGoalDTO goalDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Goal updateGoal = goalService.updateGoal(id, goalDTO);
            return ResponseEntity.ok(updateGoal);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PutMapping("changeStatus/{id}")
    public ResponseEntity<?> ChangeGoalStatus(@PathVariable int id, @RequestBody ChangeGoalStatusDTO statusDTO) {
        try {

            Goal updateGoalStatus = goalService.changeGoalStatusById(id, statusDTO);
            return ResponseEntity.ok(updateGoalStatus);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @DeleteMapping("delete/{id}")
    public ResponseEntity<?> DeleteGoal(@PathVariable int id) {
        try {
            goalService.deleteGoal(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PostMapping("reminder")
    public ResponseEntity<?> sendReminderNotifications() {
        try {
            goalService.checkAndNotifyUnfinishedGoals();
            return ResponseEntity.ok("Reminders sent successfully.");
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body("Error while sending reminders: " + e.getMessage());
        }
    }

    //================================== GOAL EXTENTION ==============================
    @PostMapping("goalExtention/{goalId}")
    public ResponseEntity<?>ExtentionGoalDealine(@PathVariable int goalId , @RequestParam boolean userResponse){
        try {
            GoalExtension goalExtension = goalExtensionService.extendGoalDeadline(goalId , userResponse);
            return ResponseEntity.status(201).body(ApiResponse.created(goalExtension,"Time extension successful"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    //================================== PROGRESS ==============================
    @PostMapping("progress/add")
    public ResponseEntity<?> AddProgress(@RequestBody ProgressDTO progressDTO) {
        try {
            Progress newProgress = progressService.createProgress(progressDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newProgress, "Create progress successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PutMapping("progress/update/{id}")
    public ResponseEntity<?> UpdateProgress(@Valid @PathVariable int id, @RequestBody UpdateProgressDTO progressDTO, BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
            Progress updateProgress = progressService.updateProgress(id, progressDTO);
            return ResponseEntity.ok(updateProgress);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @DeleteMapping("progress/delete/{id}")
    public ResponseEntity<?> DeleteProgress(@PathVariable int id) {
        try {
            progressService.deleteProgress(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @GetMapping("compare-progress")
    public ResponseEntity<?> compareProgress(@RequestParam int userId,@RequestParam int goalId, @RequestParam String startDate, @RequestParam String endDate) {
        try {
            //Chuyển đổi chuỗi thành LocalDate
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);

            //Phân tích tiến trình người dùng
            String result = progressService.analyzeProgress(userId, goalId,start, end);
            return ResponseEntity.status(200).body(ApiResponse.success(result, "Get progress data successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @DeleteMapping("dietPlan/delete/{id}")
    public ResponseEntity<?> DeleteDietPlan(@PathVariable int id) {
        try {
            dietPlanService.deleteDietPlan(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PostMapping("/approvePoint/{userId}")
    public ResponseEntity<?> approvePoint(@PathVariable Long userId,@RequestParam int point) {
        try {
            UserPoinDTO result = userPointService.approvePoint(userId, point);
            return ResponseEntity.ok(ApiResponse.success(result, "Change points successfully"));
        } catch (Exception ex) {
            if (ex.getMessage().contains("UserNotFound")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("user not found"));
            }
            if (ex.getMessage().contains("NotEnoughPointsToDeduct")) {
                return ResponseEntity.status(409).body(ApiResponse.conflict("Not Enough Points To Deduct"));
            }
            if (ex.getMessage().contains("InvalidPointId")) {
                return ResponseEntity.status(423).body(ApiResponse.resourceLocked("Invalid PointId"));
            }
            return ResponseEntity.status(500)
                    .body(ApiResponse.errorServer("Server error: " + ex.getMessage()));
        }
    }
}
