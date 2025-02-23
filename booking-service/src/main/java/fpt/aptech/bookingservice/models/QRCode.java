package fpt.aptech.bookingservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "qr_code")
@Builder
public class QRCode {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @OneToOne
    @JoinColumn(name="booking_room_id", referencedColumnName = "id")
    private BookingRoom bookingRoom;

    private String qrCodeUrl;
    @Enumerated(EnumType.STRING)
    private QRCodeStatus qrCodeStatus;
    private LocalDateTime createdAt;
}
