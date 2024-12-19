package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Goal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface GoalRepository extends JpaRepository<Goal, Integer> {
    //Tìm mục goal theo userId
    List<Goal> findGoalByUserId(@Param("userId") int userId);
}
