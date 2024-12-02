package fpt.aptech.fitnessgoalservice.controller;

import fpt.aptech.fitnessgoalservice.dtos.*;
import fpt.aptech.fitnessgoalservice.helper.ApiResponse;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.service.GoalService;
import fpt.aptech.fitnessgoalservice.service.ProgressService;
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
    private final ProgressService progressService;

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

    //================================== PROGRESS ==============================
    @PostMapping("/progress/add")
    public ResponseEntity<?> AddProgress(@RequestBody ProgressDTO progressDTO) {
        try {
            Progress newProgress = progressService.createProgress(progressDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(newProgress,"Create progress successfully") );
        }catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @PutMapping("/progress/update/{id}")
    public ResponseEntity<?> UpdateProgress(@Valid @PathVariable int id, @RequestBody UpdateProgressDTO progressDTO , BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));            }
            Progress updateProgress = progressService.updateProgress(id, progressDTO);
            return ResponseEntity.ok(updateProgress);
        }catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }

    @DeleteMapping("/progress/delete/{id}")
    public ResponseEntity<?> DeleteProgress(@PathVariable int id) {
        try {
            progressService.deleteProgress(id);
            return ResponseEntity.ok().build();
        }
        catch (Exception e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Error server : ")+ e.getMessage());
        }
    }
}
