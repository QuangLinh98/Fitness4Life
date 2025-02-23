package fpt.aptech.dashboardservice.jwt_util;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
//FeignClientInterceptor Dùng để tự động thêm JWT vào các yêu cầu HTTP gửi đi từ Feign Client, giúp các microservices liên lạc với nhau một cách bảo mật và xác thực.
// đồng thời bỏ qua xác thực cho các endpoint cụ thể nếu cần.
public class FeignClientInterceptor implements RequestInterceptor {

    @Override
    public void apply(RequestTemplate requestTemplate) {
        String url = requestTemplate.url(); // Lấy URL của request

        // Kiểm tra nếu URL thuộc endpoint không cần xác thực khi gửi feign client
        if (url.startsWith("/api/booking/package")) {
            System.out.println("Skipping Authorization for URL: " + url);
            return; // Bỏ qua thêm Authorization header
        }

        // Lấy Authentication từ SecurityContextHolder
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication.getCredentials() != null) {
            // Lấy token từ Authentication
            String token = authentication.getCredentials().toString();

            // Đảm bảo không thêm tiền tố Bearer nhiều lần
            if (!token.startsWith("Bearer ")) {
                token = "Bearer " + token;
            }

            // Đảm bảo header Authorization không bị ghi đè nhiều lần
            if (!requestTemplate.headers().containsKey("Authorization")) {
                requestTemplate.header("Authorization", token);
            }
        }
    }
}

/*
* Lưu đồ hoạt động
  1- Client gửi yêu cầu HTTP với JWT token trong header.
  2- Interceptor thêm token vào các yêu cầu Feign Client khi giao tiếp với microservices khác.
  3- Microservice nhận yêu cầu, dùng JwtUtil để xác thực token và xử lý thông tin.
* */
