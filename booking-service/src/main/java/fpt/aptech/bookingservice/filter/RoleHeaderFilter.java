package fpt.aptech.bookingservice.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Component
public class RoleHeaderFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String authorizationHeader = request.getHeader("Authorization");

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            String token = authorizationHeader.substring(7); // Lấy token từ header Authorization
            System.out.println("Token được lấy" + token);

            try {
                // Giải mã payload của JWT (không kiểm tra chữ ký)
                String[] parts = token.split("\\.");
                if (parts.length != 3) {
                    throw new IllegalArgumentException("Invalid JWT format");
                }
                String payload = new String(Base64.getUrlDecoder().decode(parts[1])); // Decode phần payload
                System.out.println("Decoded payload: " + payload);

                // Chuyển payload JSON thành Map
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> claims = mapper.readValue(payload, Map.class);

                // Lấy thông tin role từ payload
                String role = (String) claims.get("role");
                if (role != null) {
                    // Thiết lập quyền trong SecurityContext
                    Authentication authentication = new UsernamePasswordAuthenticationToken(
                            null, null, List.of(new SimpleGrantedAuthority(role))
                    );
                    System.out.println("Role : " + role);
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            } catch (Exception e) {
                System.err.println("Error while parsing JWT: " + e.getMessage());
            }
        }

        filterChain.doFilter(request, response); // Tiếp tục chuỗi lọc
    }
}
