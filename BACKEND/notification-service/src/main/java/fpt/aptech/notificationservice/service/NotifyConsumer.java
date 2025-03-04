package fpt.aptech.notificationservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.notificationservice.dtos.NotifyDTO;
import fpt.aptech.notificationservice.dtos.UserDTO;
import fpt.aptech.notificationservice.eureka_client.UserEurekaClient;
import fpt.aptech.notificationservice.mail.MailEntity;
import fpt.aptech.notificationservice.mail.MailResetPass;
import fpt.aptech.notificationservice.models.Notify;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
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
    @Autowired
    private SimpMessagingTemplate messagingTemplate;  //Dùng để gửi tin nhắn qua template


    @KafkaListener(topics = "notifyFitness_topic", groupId = "notifyFitness-group", concurrency = "3")
    public void listen(String message) {
        try {
            NotifyDTO notifyDTO = objectMapper.readValue(message, NotifyDTO.class);
            System.out.println("Received token: " + notifyDTO.getToken());

            Notify notify = objectMapper.convertValue(notifyDTO, Notify.class);
            notifyService.addNotify(notify);

        }
        catch (Exception e) {
            e.printStackTrace();
            System.out.println("Failed to process feed message: " + e.getMessage());
        }
    }


}
