package data.smartdeals_service.services.notification;//package data.smartdeals_service.services.notification;
//
//import com.fasterxml.jackson.core.JsonProcessingException;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import data.smartdeals_service.dto.notify.NotifyDTO;
//import data.smartdeals_service.dto.user.UserDTO;
//import data.smartdeals_service.services.kafkaServices.NotifyProducer;
//import jakarta.servlet.http.HttpServletRequest;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//public class NotifyService {
//    private final NotifyProducer notifyProducer;
//    private final HttpServletRequest request;
//    private final ObjectMapper objectMapper;
//
//    public void sendCreatedNotification(UserDTO existingUser, NotifyDTO notifyDTO) throws JsonProcessingException {
//
////        //Thiết lập thông báo
////        notifyDTO = NotifyDTO.builder()
////                .itemId(notifyDTO.getItemId())
////                .userId(notifyDTO.getUserId())
////                .fullName(existingUser.getFullName())
////                .title("Chao mung " + existingUser.getFullName() + " đen voi muc tieu " +goalDTO.getGoalType())
////                .content("Chuc ban som hoan thanh đuoc muc tieu đe ra.")
////                //.token(token)
////                .build();
////        // Gửi thông báo thông qua NotifyProducer
////        notifyProducer.sendNotify(notifyDTO);
//        System.out.println("Message gửi qua Kafka: " + objectMapper.writeValueAsString(notifyDTO));
//
//    }
//}
