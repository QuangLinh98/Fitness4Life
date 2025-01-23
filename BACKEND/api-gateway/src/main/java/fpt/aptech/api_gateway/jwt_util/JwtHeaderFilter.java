package fpt.aptech.api_gateway.jwt_util;

import jakarta.ws.rs.core.HttpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;


public class JwtHeaderFilter implements GlobalFilter {
    private final JwtUtil jwtUtil; // Lớp tiện ích để xử lý JWT

    public JwtHeaderFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().toString();

        // Bỏ qua endpoint không cần xác thực
        if (path.startsWith("/api/booking/qrCode/validate")) {
            System.out.println("Skipping JwtHeaderFilter for: " + path);
            return chain.filter(exchange); // Bỏ qua filter
        }
        if (path.startsWith("/api/users/verify-account")) {
            System.out.println("Skipping JwtHeaderFilter for: " + path);
            return chain.filter(exchange); // Bỏ qua filter
        }

        // Lấy Authorization header
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7); // Trích xuất token (bỏ chuỗi "Bearer ")

            // Giải mã token và thêm thông tin vào header
            try {
                String role = jwtUtil.extractUserRole(token);
                String username = jwtUtil.extractUserId(token);

                ServerWebExchange mutatedExchange = exchange.mutate()
                        .request(builder -> builder
                                .header("X-Role", role)
                                .header("X-Username", username)
                        )
                        .build();

                return chain.filter(mutatedExchange);
            } catch (Exception e) {
                System.out.println("Failed to decode token: " + e.getMessage());
            }
        }

        // Tiếp tục chuỗi filter nếu không có Authorization header
        return chain.filter(exchange);
    }
}
