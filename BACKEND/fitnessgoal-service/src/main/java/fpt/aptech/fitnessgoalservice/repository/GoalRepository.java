package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Goal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface GoalRepository extends JpaRepository<Goal, Integer> {
    //Tìm mục goal theo userId
    Goal findGoalByUserId(int userId);
}
