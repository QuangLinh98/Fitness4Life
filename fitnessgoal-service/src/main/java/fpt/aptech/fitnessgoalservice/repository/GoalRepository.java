package fpt.aptech.fitnessgoalservice.repository;

import fpt.aptech.fitnessgoalservice.models.Goal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface GoalRepository extends JpaRepository<Goal, Integer> {
    //Tìm mục goal theo userId
    List<Goal> findGoalByUserId(@Param("userId") int userId);

    // Truy vấn tìm các mục tiêu chưa hoàn thành trước một ngày cụ thể
    @Query("SELECT g FROM Goal g WHERE g.endDate = :endDate AND " +
            "(SELECT MAX(p.value) FROM g.progresses p) < :progress")
    List<Goal> findByEndDateBeforeAndProgressLessThan(LocalDate endDate, double progress);

    // Lấy các mục tiêu hết hạn hôm nay và chưa hoàn thành
    @Query("SELECT g FROM Goal g LEFT JOIN FETCH g.progresses WHERE g.endDate = :endDate")
    List<Goal> findByEndDateAndProgressLessThan(@Param("endDate") LocalDate endDate);

}
