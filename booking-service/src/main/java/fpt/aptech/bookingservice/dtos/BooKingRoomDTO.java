package fpt.aptech.bookingservice.dtos;

import fpt.aptech.bookingservice.models.BookingStatus;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BooKingRoomDTO {
    @NotNull(message = "UserId is required")
    private int userId;
    private int qrCodeId;
    private String userName;

    @NotNull(message = "RoomId is required")
    private int roomId;
    private String roomName;

    private LocalDateTime bookingDate;

    @Enumerated(EnumType.STRING)
    private BookingStatus status;  //Trạng thái Pending , Confirmed , Cancel
    private LocalDateTime createAt;
}
