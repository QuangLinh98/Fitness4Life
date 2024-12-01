package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.dtos.GoalDTO;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.service.GoalService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/goal")
@RequiredArgsConstructor
public class PublicController {
    private final GoalService goalService;

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
}
