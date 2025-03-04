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

    //Phương thức lấy data
    public List<Notify> findAll() {
        return notifyRepository.findAll();
    }

    //Phương thức tìm Goal theo id
    public Notify findById(int id) {
        return notifyRepository.findById(id).orElse(null);
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

}
