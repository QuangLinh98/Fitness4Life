package fpt.aptech.api_gateway.config;

import fpt.aptech.api_gateway.jwt_util.JwtAuthenticationFilter;
import fpt.aptech.api_gateway.jwt_util.JwtHeaderFilter;
import fpt.aptech.api_gateway.jwt_util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.SecurityWebFiltersOrder;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.web.server.ServerAuthenticationEntryPoint;
import org.springframework.security.web.server.authentication.HttpStatusServerEntryPoint;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.web.server.WebFilter;
import javax.crypto.spec.SecretKeySpec;
import java.util.List;

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {
    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http)  throws Exception {
        http.csrf(ServerHttpSecurity.CsrfSpec::disable) // Bỏ qua CSRF cho API
                .authorizeExchange(
                        exchange  -> exchange
                                //thêm mới - dùng để cho phép Options
                                .pathMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                                .pathMatchers(
                                        "/api/users/login",
                                        "/api/users/register",
                                        "/api/users/verify-account/**",
                                        "/api/users/send-otp",
                                        "/api/users/reset-password",
                                        "/api/users/change-pass",
                                        "/api/users/refresh_token",
                                        "/api/booking/qrCode/validate",
                                        "/uploads/**"
                                )
                                .permitAll()
                                .pathMatchers("/api/users/**").hasAnyAuthority("ADMIN", "USER")  // Cả ADMIN và USER đều có thể truy cập các endpoint này
                                .pathMatchers("/api/booking/**").hasAnyAuthority("USER","ADMIN")
                                .pathMatchers("/api/paypal/**").hasAnyAuthority("USER","ADMIN")
                                .pathMatchers("/api/dashboard/**").hasAnyAuthority("ADMIN", "MANAGER","USER")
                                .pathMatchers("/api/goal/**").hasAnyAuthority("ADMIN", "USER")
                                .pathMatchers("/api/deal/**").hasAnyAuthority("ADMIN", "USER")
                                .pathMatchers("/api/notify/**").hasAnyAuthority("ADMIN", "USER")
                                .anyExchange()
                                .authenticated() // Các yêu cầu khác cần xác thực
                )
                //thêm dùng để check và xác định cors được chạy trước
                .addFilterBefore(corsWebFilter(), SecurityWebFiltersOrder.CORS)
                .addFilterAt(jwtAuthenticationFilter, SecurityWebFiltersOrder.AUTHENTICATION)
                .exceptionHandling(exceptionHandling -> exceptionHandling
                        .authenticationEntryPoint((exchange, e) -> {
                            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                            return exchange.getResponse().setComplete();
                        })
                        .accessDeniedHandler((exchange, e) -> {
                            exchange.getResponse().setStatusCode(HttpStatus.FORBIDDEN);
                            return exchange.getResponse().setComplete();
                        })
                );
        return http.build();
    }

    @Bean
    public ServerAuthenticationEntryPoint authenticationEntryPoint() {
        return new HttpStatusServerEntryPoint(HttpStatus.UNAUTHORIZED);
    }

    @Bean
    public JwtDecoder jwtDecoder(JwtProperties jwtProperties) {
        return NimbusJwtDecoder.withSecretKey(
                new SecretKeySpec(jwtProperties.getSecretKey().getBytes(), "HmacSHA384")
        ).build();
    }

    @Bean
    public GlobalFilter loggingFilter() {
        return (exchange, chain) -> {
            System.out.println("Authorization Header at Gateway: " + exchange.getRequest().getHeaders().getFirst("Authorization"));
            return chain.filter(exchange);
        };
    }

    @Bean
    public GlobalFilter jwtHeaderFilter(JwtUtil jwtUtil) {
        return new JwtHeaderFilter(jwtUtil); // Đăng ký filter
    }

    // Cấu hình CORS toàn cầu
    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfig = new CorsConfiguration();
        // chỏ phép 1 đường dẫn cụ thể hoạt động
        corsConfig.setAllowedOrigins(List.of("http://localhost:3000"));
        corsConfig.setAllowedHeaders(List.of("*"));
        corsConfig.setAllowedMethods(List.of("GET", "POST", "OPTIONS", "PUT", "DELETE"));
        corsConfig.setAllowCredentials(true); // Cho phép gửi thông tin xác thực
        corsConfig.setMaxAge(3600L); // Thời gian cache cho phép là 1 giờ
        //thêm Cho phép đọc headers
        corsConfig.setExposedHeaders(List.of("Authorization", "X-Username", "X-Role"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig); // Áp dụng cho tất cả các đường dẫn
        return new CorsWebFilter(source);
    }

    // thêm dùng để loại bỏ 1 số Header ko cần thiết và chạy nhiều
    @Bean
    public WebFilter removeVaryHeader() {
        return (exchange, chain) -> {
            exchange.getResponse().getHeaders().remove("Vary");
            return chain.filter(exchange);
        };
    }


}
