package fpt.aptech.fitnessgoalservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="user_points")
public class UserPoint {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private long userId;
    @Column(nullable = false)
    private int totalPoints = 0;   // Tổng số điểm hiện tại của học viên

    public UserPoint(long userId, int totalPoints) {
        this.userId = userId;         // Gán giá trị `userId`
        this.totalPoints = totalPoints;
    }
}
