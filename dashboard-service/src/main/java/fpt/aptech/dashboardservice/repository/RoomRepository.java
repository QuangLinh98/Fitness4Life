package fpt.aptech.dashboardservice.repository;

import fpt.aptech.dashboardservice.models.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.sql.Time;
import java.time.LocalTime;

public interface RoomRepository extends JpaRepository<Room, Integer> {

}
