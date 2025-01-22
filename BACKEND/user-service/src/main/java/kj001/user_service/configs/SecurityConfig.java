package kj001.user_service.configs;

import kj001.user_service.filter.JwtAuthenticationFilter;

import kj001.user_service.filter.RoleHeaderFilter;
import kj001.user_service.service.UserDetailsServiceImp;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

import javax.crypto.spec.SecretKeySpec;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    // Inject dependency của UserDetailsServiceImp để quản lý thông tin người dùng
    private final UserDetailsServiceImp userDetailsServiceImp;

    // Inject JwtAuthenticationFilter để xử lý xác thực JWT
    private final JwtAuthenticationFilter jwtAuthenticationFilter;


    //Inject CustomLogoutHandler để xử lý logout tùy chỉnh
    private final CustomLogoutHandler logoutHandler;

    // Constructor injection cho các dependency
    public SecurityConfig(UserDetailsServiceImp userDetailsServiceImp,
                          CustomLogoutHandler logoutHandler,
                          JwtAuthenticationFilter jwtAuthenticationFilter

    ) {
        this.userDetailsServiceImp = userDetailsServiceImp;
        this.logoutHandler = logoutHandler;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth
                                .requestMatchers("/api/users/logout")
                                .authenticated()
                                .anyRequest()
                                .permitAll()
                              //.authenticated()
                )
                .addFilterBefore(new RoleHeaderFilter(), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                // Cấu hình logout
                .logout(l -> l
                        .logoutUrl("/api/users/logout") // Định nghĩa URL logout
                        .addLogoutHandler(logoutHandler) // Thêm handler xử lý logout tùy chỉnh
                        .logoutSuccessHandler((request, response, authentication) ->
                                SecurityContextHolder.clearContext()) // Xóa thông tin bảo mật sau khi logout
                );
        return http.build();
    }


    // Định nghĩa bean AuthenticationManager để quản lý xác thực
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager(); // Lấy AuthenticationManager từ cấu hình hiện tại
    }
}