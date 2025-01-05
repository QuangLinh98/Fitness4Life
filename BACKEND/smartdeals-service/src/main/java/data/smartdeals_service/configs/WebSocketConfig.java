//package data.smartdeals_service.configs;
//
//import org.springframework.context.annotation.Configuration;
//import org.springframework.messaging.simp.config.MessageBrokerRegistry;
//import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
//import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
//import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
//
//@Configuration
//@EnableWebSocketMessageBroker
//public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
//
//    @Override
//    public void configureMessageBroker(MessageBrokerRegistry registry) {
//        registry.enableSimpleBroker("/topic"); // Dùng cho gửi tin nhắn đến tất cả
//        registry.setApplicationDestinationPrefixes("/app"); // Tiền tố cho các request từ client
//    }
//
//    @Override
//    public void registerStompEndpoints(StompEndpointRegistry registry) {
//        registry.addEndpoint("/ws") // Điểm để client kết nối
//                .setAllowedOriginPatterns("*") // Cho phép mọi domain kết nối
//                .withSockJS(); // Kích hoạt SockJS fallback
//    }
//}
