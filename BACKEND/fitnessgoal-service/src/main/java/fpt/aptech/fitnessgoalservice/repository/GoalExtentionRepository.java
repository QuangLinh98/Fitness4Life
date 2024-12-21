package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.GoalExtension;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GoalExtentionRepository extends JpaRepository<GoalExtension , Integer> {
    List<GoalExtension> findByGoalId(int goalId);
}
