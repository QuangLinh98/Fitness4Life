package fpt.aptech.bookingservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "book_rooms")
public class BookingRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private int userId;
    private int roomId;
    private LocalDateTime bookingDate;
    @
    private BookingStatus status;  //Trạng thái Pending , Confirmed , Cancel
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
