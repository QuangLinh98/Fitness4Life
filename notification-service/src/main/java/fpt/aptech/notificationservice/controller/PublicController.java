package fpt.aptech.notificationservice.controller;

import fpt.aptech.notificationservice.models.Notify;
import fpt.aptech.notificationservice.service.NotifyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


import java.util.List;

@RestController
@RequestMapping("/api/notify/")
public class PublicController {
    @Autowired
    private  NotifyService notifyService;

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
}
