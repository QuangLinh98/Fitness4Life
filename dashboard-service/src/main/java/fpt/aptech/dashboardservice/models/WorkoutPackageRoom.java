package fpt.aptech.dashboardservice.models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "workout_package_room")
public class WorkoutPackageRoom {
    @Id
    @GeneratedValue
    private Long id;
    private int workoutPackageId;
    private int roomId;
}
