package fpt.aptech.api_gateway.jwt_util;


import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;

import java.util.List;

@Component
public class JwtAuthenticationFilter implements WebFilter {
    private final JwtUtil jwtUtil;

    public JwtAuthenticationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        System.out.println("JWT Filter Triggered: " + exchange.getRequest().getURI());

        // Bỏ qua xác thực cho các endpoint không cần JWT
        String path = exchange.getRequest().getPath().toString();
        if (path.startsWith("/api/users/login") ||
                path.startsWith("/api/users/register") ||
                path.startsWith("\"/api/users/verify-account/**\", \"/api/users/verify-account/*\"") ||
                path.startsWith("/api/users/send-otp") ||
                path.startsWith("/api/users/reset-password") ||
                path.startsWith("/api/users/refresh_token") ||
                path.startsWith("/api/booking/qrCode/validate")){
            System.out.println("Skipping JWT filter for: " + path);
            return chain.filter(exchange);
        }

        // Lấy Authorization header
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        // Kiểm tra xem header có hợp lệ không (có bắt đầu với "Bearer " không)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("Authorization header missing or invalid");
            return chain.filter(exchange);
        }

        // Trích xuất token từ header (bỏ qua chuỗi "Bearer ")
        String token = authHeader.substring(7);
        try {
            // Kiểm tra token hợp lệ
            String role = jwtUtil.extractUserRole(token);   //Giải mã lấy role từ token
            String username = jwtUtil.extractUserId(token); // Giải mã lấy username từ token

            if (jwtUtil.validateToken(token)) {

                // Nếu hợp lệ thêm thông tin vào header
                ServerWebExchange mutatedExchange = exchange.mutate()
                        .request(exchange.getRequest().mutate()
                                .header("X-Username", username)
                                .header("X-Role", role)
                                .build())
                        .build();
                //Thiết lập SecurityContext cho ReactiveSecurity
                return chain.filter(mutatedExchange)
                        .contextWrite(context -> ReactiveSecurityContextHolder.withAuthentication(
                                new UsernamePasswordAuthenticationToken(
                                        username,
                                        null,
                                        List.of(new SimpleGrantedAuthority(role)))
                        ));
            }else {
                System.out.println("Invalid JWT token");
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            }
        } catch (Exception e) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
    }
}
