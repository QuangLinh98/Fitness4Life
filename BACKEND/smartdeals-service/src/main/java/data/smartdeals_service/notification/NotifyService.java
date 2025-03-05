package data.smartdeals_service.notification;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import data.smartdeals_service.dto.NotifyDTO;
import data.smartdeals_service.dto.user.UserDTO;
import data.smartdeals_service.kafka.NotifyProducer;
import data.smartdeals_service.models.comment.Comment;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotifyService {
    private final NotifyProducer notifyProducer;
    private final HttpServletRequest request;
    private final ObjectMapper objectMapper;

    public void sendCreatedNotification(UserDTO existingUser, NotifyDTO notifyDTO , Comment comment) throws JsonProcessingException {
        notifyDTO = NotifyDTO.builder()
                .itemId(notifyDTO.getItemId())
                .userId(notifyDTO.getUserId())
                .fullName(notifyDTO.getFullName())
                .title("Question of title "+ comment.getQuestion().getTitle() +" in forum for you - "+existingUser.getFullName() )
                .content(" được " + comment.getUserName()+" comment với nội dung là " +comment.getContent())
                .token(notifyDTO.getToken())
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
        System.out.println("Message gửi qua Kafka: " + objectMapper.writeValueAsString(notifyDTO));
    }
    public void sendReplyOfComentNotification(UserDTO existingUser, NotifyDTO notifyDTO , Comment comment) throws JsonProcessingException {
        notifyDTO = NotifyDTO.builder()
                .itemId(comment.getParentComment().getId())
                .userId(comment.getParentComment().getUserId())
                .fullName(comment.getParentComment().getUserName())
                .title("Comment của bạn được "+ comment.getUserName()+" phản hồi ")
                .content(" với nội dung : " +comment.getContent())
                .token(notifyDTO.getToken())
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendReplyNotify(notifyDTO);
        System.out.println("Message reply gửi qua Kafka: " + objectMapper.writeValueAsString(notifyDTO));
    }

}
