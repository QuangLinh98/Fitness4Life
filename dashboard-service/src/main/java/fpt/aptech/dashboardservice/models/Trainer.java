package fpt.aptech.dashboardservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "trainers")
@Builder
public class  Trainer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String fullName;
    private String slug;
    private String photo;
    private String specialization;
    private double experienceYear;
    private String certificate;
    private String phoneNumber;

    @ElementCollection(targetClass = ScheduleTrainer.class)
    @CollectionTable(name = "schedule_trainers", joinColumns = @JoinColumn(name = "trainer_id"))
    @Column(name = "scheduleTrainers", nullable = false)
    @Enumerated(EnumType.STRING)
    private List<ScheduleTrainer> scheduleTrainers;

    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @OneToMany(mappedBy = "trainer",cascade = CascadeType.ALL)
    private List<Room> rooms;

}
