package fpt.aptech.notificationservice.repository;

import fpt.aptech.notificationservice.models.Notify;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotifyRepository extends JpaRepository<Notify, Integer> {
    // Method to find notifications by userId
    List<Notify> findByUserId(Long userId);

    // Optional: Find unread notifications by userId
    List<Notify> findByUserIdAndStatusFalse(Long userId);

    // Optional: Find by userId and order by creation date (most recent first)
    List<Notify> findByUserIdOrderByCreatedDateDesc(Long userId);
}