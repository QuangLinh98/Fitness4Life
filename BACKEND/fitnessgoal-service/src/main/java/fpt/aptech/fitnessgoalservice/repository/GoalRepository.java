package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Goal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GoalRepository extends JpaRepository<Goal, Integer> {
}
