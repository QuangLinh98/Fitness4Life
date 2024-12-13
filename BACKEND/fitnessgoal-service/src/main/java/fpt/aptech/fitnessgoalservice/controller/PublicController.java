package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.models.ExerciseDietSuggestions;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.service.ExerciseDietSuggestionsService;
import fpt.aptech.fitnessgoalservice.service.GoalService;
import fpt.aptech.fitnessgoalservice.service.ProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/goal")
@RequiredArgsConstructor
public class PublicController {
    private final GoalService goalService;
    private final ProgressService progressService;
    private final ExerciseDietSuggestionsService dietPlanService;
    //private final CalculationService calculationService;

    @GetMapping("/all")
    public ResponseEntity<?>GetAllGoal() {
        try {
            List<Goal> goals = goalService.getAllGoals();
            return ResponseEntity.ok(goals);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    //============================ PROGRESS ===========================
    @GetMapping("/progress/all")
    public ResponseEntity<?>GetAllProcessGoal() {
        try {
            List<Progress> progresses = progressService.getAllProgress();
            return ResponseEntity.ok(progresses);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("/process/{id}")
    public ResponseEntity<?>GetOneProcessGoal(@PathVariable int id) {
        try {
            Progress progress = progressService.getProgressById(id);
            return ResponseEntity.ok(progress);
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
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

    //============================ Diet Plan ===========================
    @GetMapping("/dietPlan/all")
    public ResponseEntity<?>GetAllDietPlans() {
        try {
            List<ExerciseDietSuggestions> dietPlans = dietPlanService.getAll();
            return ResponseEntity.status(200).body(ApiResponse.success(dietPlans,"Get All diet plan successfully"));
        }
        catch(Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @GetMapping("/dietPlan/{id}")
    public ResponseEntity<?>GetOneDietPlan(@PathVariable int id) {
        try {
            ExerciseDietSuggestions dietPlan = dietPlanService.getById(id);
            return ResponseEntity.status(200).body(ApiResponse.success(dietPlan,"Get diet plan successfully"));
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

}
