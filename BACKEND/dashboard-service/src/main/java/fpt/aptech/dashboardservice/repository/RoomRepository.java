package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.Room;
import fpt.aptech.dashboardservice.models.Trainer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.sql.Time;
import java.time.LocalTime;
import java.util.List;

public interface RoomRepository extends JpaRepository<Room, Integer> {
    @Query("SELECT r.trainer FROM Room r WHERE r.id = :roomId")
    Trainer findTrainerByRoomId(@Param("roomId") int roomId);

    @Query("SELECT r FROM Room r WHERE r.trainer.branch.id = :branchId")
    List<Room> findRoomsByBranchId(@Param("branchId") int branchId);
}
