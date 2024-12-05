package fpt.aptech.notificationservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "notifies")
@Builder
public class Notify {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private int itemId;
    private Long userId;
    private String fullName;
    private String title;
    private LocalDateTime createdDate;
    private String content;
    private boolean status;
    private boolean deleteItem;
}
