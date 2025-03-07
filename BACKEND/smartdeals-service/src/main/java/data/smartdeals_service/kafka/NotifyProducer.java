package data.smartdeals_service.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.dto.NotifyDTO;
import lombok.AllArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

//Hàm Gửi message
@Service
@AllArgsConstructor
public class NotifyProducer {
    //kafkaTemplate để gửi message đến kafka
    private final KafkaTemplate<String, String> kafkaTemplate;
    //Chuyển đổi đối tương thành JSon
    private final ObjectMapper objectMapper;

    public void sendNotify(NotifyDTO notifyDTO) {
        try {
            //Lấy dữ liệu trên session
            String notifyJson = objectMapper.writeValueAsString(notifyDTO);
            //Gửi chuỗi Json đến kafka . Vì Kafka không nhận Object
            this.kafkaTemplate.send("notifyForum_topic", notifyJson);
        }
        catch (Exception e) {
            System.out.println("Failed to send notify "+e.getMessage());
        }
    }
    public void sendReplyNotify(NotifyDTO notifyDTO) {
        try {
            //Lấy dữ liệu trên session
            String notifyJson = objectMapper.writeValueAsString(notifyDTO);
            //Gửi chuỗi Json đến kafka . Vì Kafka không nhận Object
            this.kafkaTemplate.send("notifyReply_topic", notifyJson);
        }
        catch (Exception e) {
            System.out.println("Failed to send notify "+e.getMessage());
        }
    }
}
