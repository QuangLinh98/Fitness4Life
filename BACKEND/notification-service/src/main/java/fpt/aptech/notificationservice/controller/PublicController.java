package fpt.aptech.notificationservice.controller;

import fpt.aptech.notificationservice.models.Notify;
import fpt.aptech.notificationservice.service.NotifyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notify/")
public class PublicController {
    @Autowired
    private NotifyService notifyService;

    @GetMapping("all")
    public ResponseEntity<?> getAllNotify() {
        try {
            List<Notify> notifies = notifyService.findAll();
            return ResponseEntity.ok(notifies);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }

    @GetMapping("{id}")
    public ResponseEntity<?> getNotifyById(@PathVariable int id) {
        try {
            Notify notify = notifyService.findById(id);
            if (notify != null) {
                return ResponseEntity.ok(notify);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }

    @GetMapping("user/{userId}")
    public ResponseEntity<?> getNotifyByUserId(@PathVariable Long userId) {
        try {
            List<Notify> notifies = notifyService.findByUserId(userId);
            return ResponseEntity.ok(notifies);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }

    @GetMapping("user/{userId}/unread")
    public ResponseEntity<?> getUnreadNotifyByUserId(@PathVariable Long userId) {
        try {
            List<Notify> notifies = notifyService.findUnreadByUserId(userId);
            return ResponseEntity.ok(notifies);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }

    @PutMapping("read/{id}")
    public ResponseEntity<?> markAsRead(@PathVariable int id) {
        try {
            Notify updatedNotify = notifyService.markAsRead(id);
            if (updatedNotify != null) {
                return ResponseEntity.ok(updatedNotify);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }
}