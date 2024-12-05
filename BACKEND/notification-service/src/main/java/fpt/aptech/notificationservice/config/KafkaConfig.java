package tripplaner.notifyservice.configs;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KafkaConfig {
    @Bean
    public NewTopic notifyToptic() {
        return new NewTopic("notify_topic", 3, (short) 3);
    }
}
