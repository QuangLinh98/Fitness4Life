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
    @Autowired
    private UserEurekaClient eurekaClient;
    @Autowired
    private MailResetPass mailResetPass;

    @KafkaListener(topics = "notifyFitness_topic", groupId = "notifyFitness-group", concurrency = "3")
    public void listen(String message) {
        try {
            NotifyDTO notifyDTO = objectMapper.readValue(message, NotifyDTO.class);

            //Sử dụng token từ các service gửi message kèm token thông qua kafka để gửi đến user-service xác thực
           // String token  = notifyDTO.getToken();

            Notify notify = objectMapper.convertValue(notifyDTO, Notify.class);
            notifyService.addNotify(notify);

            //Gửi thông báo qua websocket
            messagingTemplate.convertAndSendToUser(
                    String.valueOf(notify.getUserId()),             //Gửi tới user
                    "/queue/notifications",         // Endpoint cá nhân hóa
                    notify                          // Nội dung thông báo
            );

            //Lấy email từ user-service thông qua feign client
//            UserDTO userDTO = eurekaClient.getUserById(notify.getUserId(),token);
//            if (userDTO != null && userDTO.getEmail() != null) {
//                //Send mail
//                String emailContent = "Xin chào " + notify.getFullName() + ",\n\n" + notify.getContent();
//                // Tạo MailEntity
//                MailEntity mailEntity = new MailEntity();
//                mailEntity.setEmail(userDTO.getEmail());
//                mailEntity.setSubject(notify.getTitle());
//                mailEntity.setContent(emailContent);
//
//                // Gửi email
//                mailResetPass.sendMailOTP(mailEntity);
//            }
        }
        catch (Exception e) {
            e.printStackTrace();
            System.out.println("Failed to process feed message: " + e.getMessage());
        }
    }


}
