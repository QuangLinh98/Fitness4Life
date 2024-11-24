package data.smartdeals_service.configs;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class kafkaConfig {
    @Bean
    public NewTopic feedbackTopic() {
        return new NewTopic("comment-topic", 3, (short) 3);
    }
}

