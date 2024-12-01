package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.dtos.ChangeGoalStatusDTO;
import fpt.aptech.fitnessgoalservice.dtos.GoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateGoalDTO;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.service.GoalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goal")
@RequiredArgsConstructor
public class ManagerController {
    private final GoalService goalService;

    @PostMapping("/add")
    public ResponseEntity<?> AddGoal(@RequestBody GoalDTO goalDTO) {
        try {
            Goal newGoal = goalService.createGoal(goalDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newGoal,"Create goal successfully") );
        }catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> UpdateGoal(@Valid @PathVariable int id, @RequestBody UpdateGoalDTO goalDTO , BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));            }
            Goal updateGoal = goalService.updateGoal(id, goalDTO);
            return ResponseEntity.ok(updateGoal);
        }catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @PutMapping("/changeStatus/{id}")
    public ResponseEntity<?> ChangeGoalStatus(@PathVariable int id, @RequestBody ChangeGoalStatusDTO statusDTO) {
        try {

            Goal updateGoalStatus = goalService.changeGoalStatusById(id, statusDTO);
            return ResponseEntity.ok(updateGoalStatus);
        }catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> DeleteGoal(@PathVariable int id) {
        try {
               goalService.deleteGoal(id);
               return ResponseEntity.ok().build();
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }
}
