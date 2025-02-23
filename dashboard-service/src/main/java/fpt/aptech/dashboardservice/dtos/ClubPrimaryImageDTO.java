package fpt.aptech.dashboardservice.dtos;

import fpt.aptech.dashboardservice.models.ClubImages;
import jakarta.persistence.CascadeType;
import jakarta.persistence.OneToMany;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
public class ClubPrimaryImageDTO {
    private int id;
    private String name;
    private String address;
    private String contactPhone;
    private String description;
    private LocalTime openHour;
    private LocalTime closeHour;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    private ClubImages primaryImage;
}
