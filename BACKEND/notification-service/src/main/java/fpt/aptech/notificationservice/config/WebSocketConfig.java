package fpt.aptech.notificationservice.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Kích hoạt broker để gửi tin nhắn tới client
        config.enableSimpleBroker("/queue", "/topic"); // Gửi thông báo tới /queue hoặc /topic
        config.setApplicationDestinationPrefixes("/app"); // Prefix cho các tin nhắn gửi từ client tới server
        config.setUserDestinationPrefix("/user"); // Cấu hình cho các thông báo gửi tới từng user
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Định nghĩa endpoint WebSocket, hỗ trợ SockJS
        registry.addEndpoint("/ws").setAllowedOrigins("*").withSockJS();
    }
}
