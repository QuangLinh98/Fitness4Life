package kj001.user_service.filter;


import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kj001.user_service.service.JwtService;
import kj001.user_service.service.UserDetailsServiceImp;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

// Đánh dấu class này là một Spring component để Spring quản lý lifecycle của nó
@Component
// Class JwtAuthenticationFilter kế thừa từ OncePerRequestFilter,
// đảm bảo chỉ thực thi một lần trên mỗi yêu cầu
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    // Khai báo các dependency cần thiết
    // Service để xử lý JWT (tạo, xác thực, trích xuất thông tin từ JWT)

    private final JwtService jwtService;
    // Service để quản lý và lấy thông tin người dùng
    private final UserDetailsServiceImp userDetailsService;

    // Constructor injection để inject các dependency
    public JwtAuthenticationFilter(JwtService jwtService,
                                   UserDetailsServiceImp userDetailsService) {
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
    }

    // Ghi đè phương thức doFilterInternal, sẽ được gọi mỗi khi có một yêu cầu HTTP
    // đi qua bộ lọc
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request, // Đối tượng yêu cầu HTTP
            @NonNull HttpServletResponse response, // Đối tượng phản hồi HTTP
            @NonNull FilterChain filterChain // Chuỗi bộ lọc tiếp theo
    ) throws ServletException, IOException {
        System.out.println("JWT Filter Triggered: " + request.getRequestURI());

        // Bỏ qua xác thực cho các endpoint không cần JWT
        if (request.getRequestURI().startsWith("/api/users/login") ||
                request.getRequestURI().startsWith("/api/users/register") ||
                request.getRequestURI().startsWith("/api/users/send-otp") ||
                request.getRequestURI().startsWith("/api/users/reset-password") ||
                request.getRequestURI().startsWith("/api/users/manager/users/{id}") ||
                request.getRequestURI().startsWith("/api/users/refresh_token") ||
                request.getRequestURI().startsWith("/api/users//verify-account/{email}/{code}")) {
            System.out.println("Skipping JWT filter for: " + request.getRequestURI());
            filterChain.doFilter(request, response);
            return;
        }

        // Lấy Authorization header từ yêu cầu
        String authHeader = request.getHeader("Authorization");
        System.out.println("auth Header : " + authHeader);
        // Kiểm tra xem header có hợp lệ không (có bắt đầu với "Bearer " không)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            // Nếu không hợp lệ, tiếp tục chuỗi bộ lọc mà không làm gì thêm
            filterChain.doFilter(request, response);
            return; // Kết thúc phương thức
        }
        // Trích xuất token từ header (bỏ qua chuỗi "Bearer ")
        String token = authHeader.substring(7);
        System.out.println("Token : " + token);
        // Lấy username từ token
        String username = jwtService.extractUsername(token);
        System.out.println("User name : " + token);
        // Nếu username hợp lệ và chưa có xác thực cho request hiện tại
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Lấy thông tin người dùng từ cơ sở dữ liệu qua email (username)
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            // Kiểm tra tính hợp lệ của token
            if (jwtService.isValid(token, userDetails)) {
                // Tạo đối tượng UsernamePasswordAuthenticationToken với thông tin người dùng và quyền hạn (authorities)
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities()
                );
                // Thiết lập chi tiết xác thực dựa trên thông tin của yêu cầu HTTP
                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );
                // Đặt thông tin xác thực vào SecurityContextHolder để hoàn tất quá trình xác thực
                SecurityContextHolder.getContext().setAuthentication(authToken);
                System.out.println("Authentication in SecurityContextHolder: " + SecurityContextHolder.getContext().getAuthentication());
                System.out.println("Authorization Header: " + request.getHeader("Authorization"));


            }else {
                System.out.println("Invalid token");
            }
        }
        // Tiếp tục chuỗi bộ lọc
        filterChain.doFilter(request, response);
    }
}

