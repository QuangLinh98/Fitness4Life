package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Progress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ProgressRepository extends JpaRepository<Progress, Integer> {
    //tìm weight mới nhất mà người dùng cập nhật
    Optional<Progress> findTopByUserIdAndMetricNameOrderByTrackingDateDesc(long useId, String metricName);
    List<Progress> findByUserId(long userId);
    List<Progress> findByUserIdAndTrackingDateBetween(int userId , LocalDate startDate, LocalDate endDate);
}
