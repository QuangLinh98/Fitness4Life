package fpt.aptech.fitnessgoalservice.config;


import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KafkaConfig {
    @Bean
    public NewTopic feedbackToptic()
    {
        return new NewTopic("feedback_topic", 3, (short) 3);
    }
}
