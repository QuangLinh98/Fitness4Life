package fpt.aptech.notificationservice.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class RoleHeaderFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        System.out.println("Request URI in RoleHeaderFilter: " + request.getRequestURI());
        String role = request.getHeader("X-Role"); // Lấy role từ header
        String token = request.getHeader("Authorization"); // Lấy token từ header
        System.out.println("Role header: " + role);
        System.out.println("Test nhận token " + token);
        if (role != null && token != null) {
            // Thiết lập quyền trong SecurityContext
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    null, token, List.of(new SimpleGrantedAuthority(role))
            );
            System.out.println("Test nhận authentication " + authentication);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        } else {
            System.out.println("Role or Authorization header is missing");
        }

        filterChain.doFilter(request, response);
    }
}
