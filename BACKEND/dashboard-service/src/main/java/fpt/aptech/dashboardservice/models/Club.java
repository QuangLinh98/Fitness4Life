package fpt.aptech.dashboardservice.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "clubs")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Club {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String name;
    private String address;
    private String contactPhone;
    private String description;
    private String slug;
    private LocalTime openHour;
    private LocalTime closeHour;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    @OneToMany(mappedBy = "club",cascade = CascadeType.ALL)
    private List<ClubImages> clubImages = new ArrayList<>();

    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Room> rooms;
}
