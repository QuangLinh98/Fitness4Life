package fpt.aptech.notificationservice.service;

import fpt.aptech.notificationservice.models.Notify;
import fpt.aptech.notificationservice.repository.NotifyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotifyService {
    private final NotifyRepository notifyRepository;

    // Phương thức lấy tất cả thông báo
    public List<Notify> findAll() {
        return notifyRepository.findAll();
    }

    // Phương thức tìm thông báo theo id
    public Notify findById(int id) {
        return notifyRepository.findById(id).orElse(null);
    }

    // Phương thức lấy thông báo theo userId
    public List<Notify> findByUserId(Long userId) {
        return notifyRepository.findByUserIdOrderByCreatedDateDesc(userId);
    }

    // Phương thức lấy thông báo chưa đọc theo userId
    public List<Notify> findUnreadByUserId(Long userId) {
        return notifyRepository.findByUserIdAndStatusFalse(userId);
    }

    //Phương thức tạo 1 Notify mới
    public Notify addNotify(Notify notify) {
        notify.setCreatedDate(LocalDateTime.now());
        return notifyRepository.save(notify);
    }

    //Phương thức delete 1 notify
    public void deleteNotify(int id) {
        Notify notifyExisting = notifyRepository.findById(id).orElse(null);
        notifyRepository.delete(notifyExisting);
    }

    // Phương thức cập nhật trạng thái đã đọc
    public Notify markAsRead(int id) {
        Notify notifyExisting = notifyRepository.findById(id).orElse(null);
        if (notifyExisting != null) {
            notifyExisting.setStatus(true);
            return notifyRepository.save(notifyExisting);
        }
        return null;
    }

}