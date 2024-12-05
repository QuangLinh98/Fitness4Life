package tripplaner.notifyservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import tripplaner.notifyservice.dtos.NotifyDTO;
import tripplaner.notifyservice.models.Notify;

//Bên này sẽ tiêu thụ
@Service
@AllArgsConstructor
public class NotifyConsumer {
    //Chuyển đổi đối tương thành JSon
    private final ObjectMapper objectMapper;
    private final NotifyService notifyService;

    @KafkaListener(topics = "notify_topic", groupId = "notify-group", concurrency = "3")
    public void listen(String message) {
        try {
            NotifyDTO notifyDTO = objectMapper.readValue(message, NotifyDTO.class);
            Notify notify = objectMapper.convertValue(notifyDTO, Notify.class);
            System.out.println(notify.toString());
            notifyService.addNotify(notify);
        }
        catch (Exception e) {
            System.out.println("Failed to process feed message: " + e.getMessage());
        }
    }
}
