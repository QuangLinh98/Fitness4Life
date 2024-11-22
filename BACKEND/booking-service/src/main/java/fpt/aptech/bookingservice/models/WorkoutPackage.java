package fpt.aptech.bookingservice.models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class WorkoutPackage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private PackageName packageName;
    private String description;
    private int durationMonth;
    private double price;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}
