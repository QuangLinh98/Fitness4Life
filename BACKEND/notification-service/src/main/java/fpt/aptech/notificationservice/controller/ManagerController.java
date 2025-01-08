package fpt.aptech.notificationservice.controller;

import fpt.aptech.notificationservice.models.Notify;
import fpt.aptech.notificationservice.service.NotifyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notify/")
public class ManagerController {
    @Autowired
    private NotifyService notifyService;

    @PostMapping("create")
    public ResponseEntity<?> createNotify(@Valid @RequestBody Notify notify,
                                              BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(bindingResult.getAllErrors());
            }

            Notify createdNotify = notifyService.addNotify(notify);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdNotify);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }

    @DeleteMapping("delete/{id}")
    public ResponseEntity<?> deleteNotify(@PathVariable int id) {
        try {
           notifyService.deleteNotify(id);
           return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body(ex);
        }
    }
}
