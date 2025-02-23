package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.WorkoutPackageRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface WorkoutPackageRoomRepository extends JpaRepository<WorkoutPackageRoom,Integer> {
    //Lấy danh sách lớp học theo gói tập
    @Query("SELECT wpr.roomId FROM WorkoutPackageRoom wpr WHERE wpr.workoutPackageId =:packageId")
    List<Integer> findRoomIdsByWorkoutPackageId(@Param("packageId") int packageId);

    // Lấy danh sách gói tập theo lớp học
    @Query("SELECT wpr.workoutPackageId FROM WorkoutPackageRoom wpr WHERE wpr.roomId = :roomId")
    List<Integer> findWorkoutPackageIdsByRoomId(@Param("roomId") int roomId);

    //Kiểm tra xem chúng có mỗi quan hệ hay không
    boolean existsByWorkoutPackageIdAndRoomId(int workoutPackageId, int classId);

   //Xóa quan hệ giữa Room và WorkoutPackage
    void deleteByWorkoutPackageIdAndRoomId(int workoutPackageId, int classId);

}
