package fpt.aptech.bookingservice.repository;

import fpt.aptech.bookingservice.models.BookingRoom;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BookingRoomRepository extends JpaRepository<BookingRoom, Integer> {
}
