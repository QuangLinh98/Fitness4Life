package kj001.user_service.models;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name="users")
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class User implements UserDetails {
    @Id
    @GeneratedValue
    private long id;
    @Column(name = "workout_package_id")
    private int workoutPackageId;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;
    private boolean isBanded = false;    //Ban Account
    private boolean isActive = false;    //Trang thái đã được xác nhân tài khoản chưa
    private String otpCode;
    private LocalDateTime expiryTime;
    private String phone;

    @Enumerated(EnumType.STRING)
    private Roles role;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private Profile profile;

    @Enumerated(EnumType.STRING)
    private Gender gender;

    private LocalDateTime createAt;

    @OneToMany(mappedBy = "user",fetch = FetchType.EAGER)
    private List<Token> tokens;

    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(role.name()));
    }
}
