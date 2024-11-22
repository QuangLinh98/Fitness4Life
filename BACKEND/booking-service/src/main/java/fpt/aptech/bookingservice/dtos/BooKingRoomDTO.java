package fpt.aptech.bookingservice.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BooKingRoomDTO {
    @NotNull(message = "UserId is required")
    private int userId;

    @NotNull(message = "RoomId is required")
    private int roomId;

    private LocalDateTime bookingDate;

    @NotNull(message = "Status is required")
    private String status;  //Trạng thái Pending , Confirmed , Cancel
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
