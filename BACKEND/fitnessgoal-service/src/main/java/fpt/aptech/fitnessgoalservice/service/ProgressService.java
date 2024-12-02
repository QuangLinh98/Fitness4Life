package fpt.aptech.fitnessgoalservice.service;

import fpt.aptech.fitnessgoalservice.dtos.ProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UpdateProgressDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.eureka_Client.UserEurekaClient;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.repository.ProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProgressService {
    private final ProgressRepository progressRepository;
    private final GoalService goalService;
    private final UserEurekaClient userEurekaClient;

    //Handle get all progress data
    public List<Progress> getAllProgress() {
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
        Goal existingGoal = goalService.getGoalById(progressDTO.getGoal());
        if (existingGoal == null) {
            throw new RuntimeException("Goal not found");
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
        return progressRepository.save(newProgress);
    }

    //Handle update a progress
    public Progress updateProgress(int id, UpdateProgressDTO updateProgressDTO) {
        Progress existingProgress = getProgressById(id);
        if (existingProgress != null) {
            existingProgress.setTrackingDate(updateProgressDTO.getTrackingDate());
            existingProgress.setMetricName(updateProgressDTO.getMetricName());
            existingProgress.setValue(updateProgressDTO.getValue());
            existingProgress.setWeight(updateProgressDTO.getWeight());
            existingProgress.setCaloriesConsumed(updateProgressDTO.getCaloriesConsumed());
            existingProgress.setUpdatedAt(LocalDateTime.now());
            return progressRepository.save(existingProgress);
        }
        throw new RuntimeException("Progress not found");
    }

    //Handle delete progress
    public void deleteProgress(int id) {
        Progress existingProgress = getProgressById(id);
        if (existingProgress != null) {
            progressRepository.delete(existingProgress);
        }
    }


}
