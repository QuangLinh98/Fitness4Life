package fpt.aptech.dashboardservice.dtos;

import fpt.aptech.dashboardservice.models.ServiceBranch;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Data
public class BranchDTO {
    @NotNull(message = "Branch name is required.")
    private String branchName;
    private String slug;
    @NotBlank(message = "Address is required.")
    private String address;
    @NotBlank(message = "Phone number is required.")
    private String phoneNumber;
    @Email(message = "Invalid email format.")
    private String email;
    @NotNull(message = "Opening hours are required.")
    private LocalTime openHours;
    @NotNull(message = "Opening hours are required.")
    private LocalTime closeHours;

    @ElementCollection(targetClass = ServiceBranch.class)
    @Enumerated(EnumType.STRING)
    private List<ServiceBranch> services;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
