package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.Progress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ProgressRepository extends JpaRepository<Progress, Integer> {
    //tìm weight mới nhất mà người dùng cập nhật
    Optional<Progress> findTopByUserIdAndMetricNameOrderByTrackingDateDesc(long useId, String metricName);
    List<Progress> findByUserId(long userId);
    // Truy vấn lấy tiến trình của người dùng theo goalId và khoảng thời gian
    List<Progress> findByUserIdAndGoalIdAndTrackingDateBetween(int userId, int goalId, LocalDate startDate, LocalDate endDate);

    boolean existsByGoalIdAndMessageContaining(int goalId, String message);

    List<Progress> findByGoalId(int goalId);
}
