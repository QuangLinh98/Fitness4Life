package fpt.aptech.bookingservice.models;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "book_rooms")
@Builder
public class BookingRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private int userId;
    private String userName;
    private int roomId;
    private String roomName;
    private LocalDateTime bookingDate;
    @Enumerated(EnumType.STRING)
    private BookingStatus status;  //Trạng thái Pending , Confirmed , Cancel
    private LocalDateTime createAt;
}
