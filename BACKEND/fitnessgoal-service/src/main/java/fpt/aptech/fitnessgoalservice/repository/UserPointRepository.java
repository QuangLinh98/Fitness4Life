package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.models.UserPoint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserPointRepository extends JpaRepository<UserPoint, Integer> {
    Optional<UserPoint> findByUserId(long userId);
}
