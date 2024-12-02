package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Progress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProgressRepository extends JpaRepository<Progress, Integer> {

    //tìm weight mới nhất mà người dùng cập nhật
    Optional<Progress> findTopByUserIdAndMetricNameOrderByTrackingDateDesc(long useId, String metricName);
}
