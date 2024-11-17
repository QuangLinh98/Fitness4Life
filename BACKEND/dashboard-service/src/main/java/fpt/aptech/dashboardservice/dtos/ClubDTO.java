package fpt.aptech.dashboardservice.dtos;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
public class ClubDTO {
    @NotNull(message = "Club name can not be null")
    private String name;

    @NotNull(message = "Address can not be null")
    @Size(max = 500, message = "Address must not exceed 500 characters")
    private String address;

    @Pattern(regexp = "^(\\+\\d{1,3}[- ]?)?\\d{10}$", message = "Invalid phone number")
    private String contactPhone;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    @NotNull(message = "Open hour cannot be null")
    private LocalTime openHour;

    @NotNull(message = "Close hour cannot be null")
    private LocalTime closeHour;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
