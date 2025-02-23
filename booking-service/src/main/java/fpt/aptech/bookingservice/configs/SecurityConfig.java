package fpt.aptech.bookingservice.configs;
import fpt.aptech.bookingservice.filter.RoleHeaderFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity

public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configure(http)) // Bậ
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/booking/qrCode/**",
                                "/uploads/qrCodeImages/**",
                                "/api/booking/package/**")
                        .permitAll()
                        .anyRequest()
                        .authenticated() // Yêu cầu tất cả endpoint cần xác thực
                )
                .addFilterBefore(new RoleHeaderFilter(), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}