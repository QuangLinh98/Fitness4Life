package kj001.user_service.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="profiles")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Profile {

    @Id
    @GeneratedValue
    private long id;
    private String hobbies;
    private String address;
    private int age;
    private int heightValue;   //Giá trị chiều cao
    private String avatar;
    private String description;

    @Enumerated(EnumType.STRING)
    private MaritalStatus maritalStatus;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    @JsonIgnore
    private User user;
}
