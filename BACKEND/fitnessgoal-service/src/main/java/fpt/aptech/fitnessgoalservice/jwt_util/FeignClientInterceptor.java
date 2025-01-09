package fpt.aptech.fitnessgoalservice.jwt_util;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
//FeignClientInterceptor Dùng để tự động thêm JWT vào các yêu cầu HTTP gửi đi từ Feign Client, giúp các microservices liên lạc với nhau một cách bảo mật và xác thực.
public class FeignClientInterceptor implements RequestInterceptor {

    @Override
    public void apply(RequestTemplate requestTemplate) {
        // Lấy Authentication từ SecurityContextHolder
//        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
//        System.out.println("Authentication la : " + authentication);
//        if (authentication != null && authentication.getCredentials() != null) {
//            // Lấy token từ Authentication
//            String token = authentication.getCredentials().toString();
//
//            // Đảm bảo không thêm tiền tố Bearer nhiều lần
//            if (!token.startsWith("Bearer ")) {
//                token = "Bearer " + token;
//            }
//
//            // Đảm bảo header Authorization không bị ghi đè nhiều lần
//            if (!requestTemplate.headers().containsKey("Authorization")) {
//                requestTemplate.header("Authorization", token);
//            }
//        }
        requestTemplate.header("Authorization", (String) null);
    }
}

/*
* Lưu đồ hoạt động
  1- Client gửi yêu cầu HTTP với JWT token trong header.
  2- Interceptor thêm token vào các yêu cầu Feign Client khi giao tiếp với microservices khác.
  3- Microservice nhận yêu cầu, dùng JwtUtil để xác thực token và xử lý thông tin.
* */
