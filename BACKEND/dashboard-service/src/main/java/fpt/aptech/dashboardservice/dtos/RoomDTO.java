package fpt.aptech.dashboardservice.dtos;

import com.fasterxml.jackson.annotation.JsonIgnore;
import fpt.aptech.dashboardservice.models.Branch;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class RoomDTO {
    private int branch;
    private int trainer;
    @NotNull(message = "Room name can not is required")
    private String roomName;
    @NotNull(message = "Capacity can not is required")
    private int capacity;    //Sức chứa của pòng
    @NotNull(message = "Facilities can not is required")
    private String facilities;
    private boolean status;    //Trạng thái của room(VD: có thể sử dụng hoặc đang bảo trì )
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
