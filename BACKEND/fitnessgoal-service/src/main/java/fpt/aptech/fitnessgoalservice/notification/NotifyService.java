package fpt.aptech.fitnessgoalservice.notification;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.fitnessgoalservice.dtos.GoalDTO;
import fpt.aptech.fitnessgoalservice.dtos.NotifyDTO;
import fpt.aptech.fitnessgoalservice.dtos.UserDTO;
import fpt.aptech.fitnessgoalservice.kafka.NotifyProducer;
import fpt.aptech.fitnessgoalservice.models.Goal;
import fpt.aptech.fitnessgoalservice.models.Progress;
import fpt.aptech.fitnessgoalservice.service.CalculationService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.Value;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotifyService {
    private final NotifyProducer notifyProducer;
    private final HttpServletRequest request;
    private final ObjectMapper objectMapper;

    public void sendCreatedNotification(UserDTO existingUser, NotifyDTO notifyDTO , GoalDTO goalDTO) throws JsonProcessingException {
        //String token = request.getHeader("Authorization"); // Lấy token từ header

        //Thiết lập thông báo
        notifyDTO = NotifyDTO.builder()
                .itemId(notifyDTO.getItemId())
                .userId(notifyDTO.getUserId())
                .fullName(existingUser.getFullName())
                .title("Chao mung " + existingUser.getFullName() + " đen voi muc tieu " +goalDTO.getGoalType())
                .content("Chuc ban som hoan thanh đuoc muc tieu đe ra.")
                //.token(token)
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
        System.out.println("Message gửi qua Kafka: " + objectMapper.writeValueAsString(notifyDTO));

    }

    //Gửi thông báo nhắc nhở về thời gian kết thúc goal
    public void sendGoalNotification(UserDTO existingUser, Goal goal) {
        String content = String.format(
                "Muc tieu '%s' cua ban se het han vao ngay %s. Hay kiem tra va cap nhat tien đo nhe!",
                goal.getGoalType(),
                goal.getEndDate()
        );
        NotifyDTO notifyDTO = NotifyDTO.builder()
                .itemId(goal.getId())
                .userId(goal.getUserId())
                .fullName(existingUser.getFullName())
                .title("Nhac nho muc tieu sap den han")
                .content(content)
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
    }

    //Gửi thông báo nhắc xác nhận gia hạn thời gian cho mục tiêu
    public void sendGoalExtendNotification(UserDTO existingUser, Goal goal) {
        // Tính tiến độ lớn nhất
        double progressPercentage = calculateGoalProgress(goal);

        String content = String.format(
                "Muc tieu '%s' cua ban se het han vao ngay %s.Tien do hien tai dat duoc :%.2f%% . Ban co muon gia han them thoi gian de hoan thanh muc tieu hay khong !",
                goal.getGoalType(),
                goal.getEndDate(),
                progressPercentage
        );
        NotifyDTO notifyDTO = NotifyDTO.builder()
                .itemId(goal.getId())
                .userId(goal.getUserId())
                .fullName(existingUser.getFullName())
                .title("Thong bao nhac nho gia han muc tieu")
                .content(content)
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
    }

    private double calculateGoalProgress(Goal goal) {
        switch (goal.getGoalType()) {
            case WEIGHT_LOSS:
                return ((goal.getWeight() - goal.getCurrentValue()) / (goal.getWeight() - goal.getTargetValue())) * 100;
            case WEIGHT_GAIN:
                return ((goal.getCurrentValue() - goal.getWeight()) / (goal.getTargetValue() - goal.getWeight())) * 100;
            case MUSCLE_GAIN:
                return (goal.getCurrentValue() / goal.getTargetValue()) * 100;
            default:
                throw new IllegalArgumentException("Unknown goal type: " + goal.getGoalType());
        }
    }

    public void sendAnalyticsNotification(UserDTO existingUser, Goal goal, String resultMessage) {
        //Thiết lập thông báo
        NotifyDTO notifyDTO = NotifyDTO.builder()
                .itemId(goal.getId())
                .userId(goal.getUserId())
                .fullName(existingUser.getFullName())
                .title("Cap nhat tien do muc tieu" )
                .content(resultMessage)
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
    }

    public void sendPointNotification(UserDTO existingUser, Goal goal, String resultMessage, int point) {
        //Thiết lập thông báo
        NotifyDTO notifyDTO = NotifyDTO.builder()
                .itemId(goal.getId())
                .userId(goal.getUserId())
                .fullName(existingUser.getFullName())
                .title("Thong bao cong diem thuong" )
                .content(resultMessage)
                .build();
        // Gửi thông báo thông qua NotifyProducer
        notifyProducer.sendNotify(notifyDTO);
    }
}
