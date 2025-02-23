package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserPoinDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.models.*;
import fpt.aptech.fitnessgoalservice.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/goal/")
@RequiredArgsConstructor
public class PublicController {
    private final GoalService goalService;
    private final GoalExtentionService goalExtentionService;
    private final ProgressService progressService;
    private final ExerciseDietSuggestionsService dietPlanService;
    private final UserPointService pointService;
    private final CalculationService calculationService;
    private final UserEurekaClient userEurekaClient;

    @GetMapping("all")
    public ResponseEntity<?>GetAllGoal() {
        try {
            List<Goal> goals = goalService.getAllGoals();
            return ResponseEntity.ok(goals);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("{id}")
    public ResponseEntity<?>GetGoalById(@PathVariable int id) {
        try {
            Goal goal = goalService.getGoalById(id);
            return ResponseEntity.ok(goal);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("user/{userId}")
    public ResponseEntity<?>GetAllGoalById(@PathVariable int userId) {
        try {
            List<Goal> goals = goalService.getGoalByUserId(userId);
            return ResponseEntity.ok(goals);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    //================================== GOAL EXTENTION ==============================
    @GetMapping("goalExtention/{goalId}")
    public ResponseEntity<?>getGoalExtensions(@PathVariable int goalId) {
        try {
           List<GoalExtension> goalExtensions = goalExtentionService.getGoalExtensions(goalId);
           return ResponseEntity.status(200).body(ApiResponse.success(goalExtensions,"Get goal extention list successfully") );
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    //============================ PROGRESS ===========================
    @GetMapping("progress/all")
    public ResponseEntity<?>GetAllProcessGoal() {
        try {
            List<Progress> progresses = progressService.getAllProgress();
            return ResponseEntity.ok(progresses);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("process/{id}")
    public ResponseEntity<?>GetOneProcessGoal(@PathVariable int id) {
        try {
            Progress progress = progressService.getProgressById(id);
            return ResponseEntity.ok(progress);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("/progress/{goalId}")
    public ResponseEntity<?> getProgressListByGoalId(@PathVariable int goalId) {
        List<Progress> progressList = progressService.getProgressByGoalId(goalId);
        return ResponseEntity.ok(progressList);
    }

    //============================ TDEE ===========================
//    @GetMapping("/tdee/{userId}/{goalId}")
//    public ResponseEntity<?>GetTdee(@PathVariable long userId, @PathVariable int goalId) {
//        try {
//            Double tdee  = calculationService.calculateTdee(userId,goalId);
//            return ResponseEntity.ok(tdee);
//        }
//        catch (Exception e) {
//            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
//        }
//    }

    @GetMapping("/bmi")
    public ResponseEntity<?> calculateBMI(
            @RequestParam double weight,
            @RequestParam Long userId) {
        // Lấy thông tin người dùng từ service
        UserDTO userDTO = userEurekaClient.getUserById(userId);
        if (userDTO == null) {
            throw new RuntimeException("User not found");
        }

        // Gọi service để tính BMI
        double bmi = calculationService.calculateBMI(weight, userDTO);
        return ResponseEntity.status(200).body(ApiResponse.success(bmi,"Get BMI successfully") );
    }

    //============================ Diet Plan ===========================
    @GetMapping("dietPlan/all")
    public ResponseEntity<?>GetAllDietPlans() {
        try {
            List<ExerciseDietSuggestions> dietPlans = dietPlanService.getAll();
            return ResponseEntity.status(200).body(ApiResponse.success(dietPlans,"Get All diet plan successfully"));
        }
        catch(Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("dietPlan/{id}")
    public ResponseEntity<?>GetOneDietPlan(@PathVariable int id) {
        try {
            ExerciseDietSuggestions dietPlan = dietPlanService.getById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(dietPlan,"Get diet plan successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    //============================ User Point ===========================

    @GetMapping("/userPoint/{userId}")
    public ResponseEntity<?> getUserPoints(@PathVariable long userId) {
        try {
            UserPoinDTO points = pointService.getUserPoint(userId);
            return ResponseEntity.status(200).body(ApiResponse.success(points,"Get user points successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

}
