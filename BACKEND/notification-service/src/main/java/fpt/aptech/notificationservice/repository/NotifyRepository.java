package fpt.aptech.notificationservice.repository;

import fpt.aptech.notificationservice.models.Notify;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotifyRepository extends JpaRepository<Notify, Integer> {
}
