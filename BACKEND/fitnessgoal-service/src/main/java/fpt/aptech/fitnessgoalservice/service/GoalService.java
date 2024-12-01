package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.ChangeGoalStatusDTO;
import fpt.aptech.fitnessgoalservice.dtos.GoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateGoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.GoalStatus;
import fpt.aptech.fitnessgoalservice.repository.GoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class GoalService {
    private final GoalRepository goalRepository;
    private final UserEurekaClient userEurekaClient;

    //Handle get all data
    public List<Goal> getAllGoals() {
        return goalRepository.findAll();
    }

    //Handle create Goal
    public Goal createGoal(GoalDTO goalDTO) {
        UserDTO existingUser = userEurekaClient.getUserById(goalDTO.getUserId());
        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }
        Goal goal = Goal.builder()
                .userId(goalDTO.getUserId())
                .fullName(existingUser.getFullName())
                .goalType(goalDTO.getGoalType())
                .targetValue(goalDTO.getTargetValue())
                .currentValue(goalDTO.getCurrentValue())
                .startDate(goalDTO.getStartDate())
                .endDate(goalDTO.getEndDate())
                .goalStatus(GoalStatus.PLANNING)
                .createdAt(LocalDateTime.now())
                .build();
        return goalRepository.save(goal);
    }

    //Handle update Goal
    public Goal updateGoal(int id, UpdateGoalDTO goalDTO) {
        Goal existingGoal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        if (existingGoal.getGoalStatus() == GoalStatus.COMPLETED) {
            throw new RuntimeException("Goal already completed");
        }
        if (existingGoal.getGoalStatus() != GoalStatus.IN_PROGRESS && existingGoal.getGoalStatus() != GoalStatus.FAILED) {
            existingGoal.setStartDate(goalDTO.getStartDate());
            existingGoal.setEndDate(goalDTO.getEndDate());
        }
        existingGoal.setGoalType(goalDTO.getGoalType());
        existingGoal.setTargetValue(goalDTO.getTargetValue());
        existingGoal.setCurrentValue(goalDTO.getCurrentValue());
        return goalRepository.save(existingGoal);
    }

    //Handle update goal status
    public Goal changeGoalStatusById(int id, ChangeGoalStatusDTO goalStatusDTO) {
        Goal existingGoal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        if (existingGoal.getGoalStatus() == GoalStatus.COMPLETED) {
            throw new RuntimeException("Error: Goal Completed");
        }
        GoalStatus newStatus = GoalStatus.valueOf(goalStatusDTO.getGoalStatus());
        if (existingGoal.getGoalStatus() == GoalStatus.IN_PROGRESS) {
            if (newStatus == GoalStatus.PLANNING ) {
                throw new RuntimeException("Error: Goal Planning");
            }
        }
        existingGoal.setGoalStatus(newStatus);
        goalRepository.save(existingGoal);
        return existingGoal;
    }

    //Handle delete Goal
    public void deleteGoal(int id) {
        Goal goal = goalRepository.findById(id).orElseThrow(() -> new RuntimeException("Goal not found"));
        goalRepository.delete(goal);
    }
}
