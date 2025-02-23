package fpt.aptech.bookingservice.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
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

    @OneToOne(mappedBy = "bookingRoom",cascade = CascadeType.ALL,orphanRemoval =true)
    @JsonBackReference
    private QRCode qrCode;

    private int userId;
    private String userName;
    private int roomId;
    private String roomName;
    private LocalDateTime bookingDate;
    @Enumerated(EnumType.STRING)
    private BookingStatus status;  //Trạng thái Pending , Confirmed , Cancel
    private LocalDateTime createAt;
}
