package fpt.aptech.bookingservice.repository;

import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.models.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BookingRoomRepository extends JpaRepository<BookingRoom, Integer> {
    List<BookingRoom> findByUserIdAndStatus(int userId, BookingStatus status);
    List<BookingRoom> findByUserId(int userId);
}
