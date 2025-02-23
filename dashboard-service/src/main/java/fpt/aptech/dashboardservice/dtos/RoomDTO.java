package fpt.aptech.dashboardservice.dtos;


import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;

import java.sql.Time;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
public class RoomDTO {
    private int club;
    private int trainer;
    @NotNull(message = "Room name can not is required")
    private String roomName;
    private String slug;
    @NotNull(message = "Capacity can not is required")
    private int capacity;    //Sức chứa của pòng
    @NotNull(message = "Facilities can not is required")
    private String facilities;
    @NotNull(message = "Status can not is required")
    private boolean status;    //Trạng thái của room(VD: có thể sử dụng hoặc đang bảo trì )
    @NotNull(message = "Start time can not is required")
    private LocalTime startTime;
    @NotNull(message = "End time can not is required")
    private LocalTime endTime;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
