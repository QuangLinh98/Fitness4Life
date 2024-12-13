package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.dtos.*;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.kafka.NotifyProducer;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.dtos.NotifyDTO;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.notification.NotifyService;
import fpt.aptech.fitnessgoalservice.service.ExerciseDietSuggestionsService;
import fpt.aptech.fitnessgoalservice.service.GoalService;
import fpt.aptech.fitnessgoalservice.service.ProgressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/goal")
@RequiredArgsConstructor
public class ManagerController {
    private final GoalService goalService;
    private final NotifyProducer notifyProducer;
    private final ProgressService progressService;
    private final ExerciseDietSuggestionsService dietPlanService;
    private final UserEurekaClient userEurekaClient;
    private final NotifyService notifyService;

    @PostMapping("/add")
    public ResponseEntity<?> AddGoal(@RequestBody GoalDTO goalDTO) {
        try {
            Goal newGoal = goalService.createGoal(goalDTO);
            //Test user
            UserDTO existingUser = userEurekaClient.getUserById(goalDTO.getUserId());
            System.out.println("Có nhận đươc user không : " + existingUser);

            //Send notification to user . When user add a goal successfully
            NotifyDTO notifyDTO = new NotifyDTO();
            notifyDTO.setItemId(newGoal.getId());
            notifyDTO.setUserId(goalDTO.getUserId());
            notifyService.sendCreatedNotification(existingUser, notifyDTO, goalDTO);

            return ResponseEntity.status(201).body(ApiResponse.created(newGoal, "Create goal successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
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

    @PutMapping("/changeStatus/{id}")
    public ResponseEntity<?> ChangeGoalStatus(@PathVariable int id, @RequestBody ChangeGoalStatusDTO statusDTO) {
        try {

            Goal updateGoalStatus = goalService.changeGoalStatusById(id, statusDTO);
            return ResponseEntity.ok(updateGoalStatus);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> DeleteGoal(@PathVariable int id) {
        try {
            goalService.deleteGoal(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }


    //================================== PROGRESS ==============================
    @PostMapping("/progress/add")
    public ResponseEntity<?> AddProgress(@RequestBody ProgressDTO progressDTO) {
        try {
            Progress newProgress = progressService.createProgress(progressDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newProgress, "Create progress successfully"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @PutMapping("/progress/update/{id}")
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

    @DeleteMapping("/progress/delete/{id}")
    public ResponseEntity<?> DeleteProgress(@PathVariable int id) {
        try {
            progressService.deleteProgress(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }

    @GetMapping("/compare-progress")
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

    //============================ Diet Plan ===========================
//    @PostMapping("/dietPlan/add")
//    public ResponseEntity<?> AddDietPlan(@RequestBody DietPlanDTO dietPlanDTO) {
//        try {
//            List<DietPlan> dietPlans = dietPlanService.createDietPlanForUser(dietPlanDTO);
//            return ResponseEntity.status(201).body(ApiResponse.created(dietPlans, "Create list diet plan successfully"));
//        } catch (Exception e) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
//        }
//    }

//    @PutMapping("/dietPlan/update/{id}")
//    public ResponseEntity<?> UpdateDietPlan(@Valid @PathVariable int id, @RequestBody UpdateDietPlanDTO dietPlanDTO, BindingResult bindingResult) {
//        try {
//            if (bindingResult.hasErrors()) {
//                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
//            }
//            DietPlan updateDietPlan = dietPlanService.updateDietPlan(id, dietPlanDTO);
//            return ResponseEntity.ok(updateDietPlan);
//        } catch (Exception e) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
//        }
//    }

    @DeleteMapping("/dietPlan/delete/{id}")
    public ResponseEntity<?> DeleteDietPlan(@PathVariable int id) {
        try {
            dietPlanService.deleteDietPlan(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ") + e.getMessage());
        }
    }
}
