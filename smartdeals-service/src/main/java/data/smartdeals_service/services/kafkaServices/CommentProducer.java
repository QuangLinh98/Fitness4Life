package data.smartdeals_service.services.kafkaServices;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CommentProducer {
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    public void sendComment(Object object) {
        try {
            String commentBackJson = objectMapper.writeValueAsString(object);
            this.kafkaTemplate.send("comment-topic",commentBackJson);;
        }catch (Exception ex) {
            System.out.println("failed to send comment"+ex.getMessage());
        }
    }

}
