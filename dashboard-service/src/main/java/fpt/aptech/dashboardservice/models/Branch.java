package fpt.aptech.dashboardservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "branchs")
public class Branch {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String branchName;
    private String slug;
    private String address;
    private String phoneNumber;
    private String email;
    private LocalTime openHours;
    private LocalTime closeHours;

    @ElementCollection(targetClass = ServiceBranch.class)
    @CollectionTable(name = "branch_services", joinColumns = @JoinColumn(name = "branch_id"))
    @Column(name = "services", nullable = false)
    @Enumerated(EnumType.STRING)
    private List<ServiceBranch> services;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    @OneToMany(mappedBy = "branch", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Trainer> trainers;


}
