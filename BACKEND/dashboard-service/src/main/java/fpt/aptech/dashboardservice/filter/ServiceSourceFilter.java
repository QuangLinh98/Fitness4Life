package fpt.aptech.dashboardservice.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
//Kiểm tra nguồn gốc của request
public class ServiceSourceFilter  extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String serviceSource = request.getHeader("X-Service-Source");

        // Chỉ cho phép request từ booking-service gửi đến mà không cần xác thực token
        if ("/api/dashboard/room".equalsIgnoreCase(request.getRequestURI()) &&
                !"booking-service".equalsIgnoreCase(serviceSource)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        filterChain.doFilter(request, response);
    }
}
