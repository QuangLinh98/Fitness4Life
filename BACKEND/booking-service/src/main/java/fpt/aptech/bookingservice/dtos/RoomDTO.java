package fpt.aptech.bookingservice.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalTime;

@Data
public class RoomDTO {
    private int id;
    private String roomName;
    private int capacity;    //Sức chứa của phòng
    private int availableSeats;    //chỗ trống hiện tại của lớp học
    private LocalTime startTime;
    private LocalTime endTime;
}
