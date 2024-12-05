package fpt.aptech.notificationservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.notificationservice.dtos.NotifyDTO;
import fpt.aptech.notificationservice.models.Notify;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.kafka.annotation.KafkaListener;

//Bên này sẽ tiêu thụ
@Service
public class NotifyConsumer {
    //Chuyển đổi đối tương thành JSon
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private NotifyService notifyService;

    @KafkaListener(topics = "notifyFitness_topic", groupId = "notifyFitness-group", concurrency = "3")
    public void listen(String message) {
        try {
            NotifyDTO notifyDTO = objectMapper.readValue(message, NotifyDTO.class);
            System.out.println("Test nhận dữ liệu : " + notifyDTO);

            Notify notify = objectMapper.convertValue(notifyDTO, Notify.class);
            System.out.println("Test chuyển đổi dữ liệu : " + notify.toString());
            notifyService.addNotify(notify);
        }
        catch (Exception e) {
            e.printStackTrace();
            System.out.println("Failed to process feed message: " + e.getMessage());
        }
    }
}
