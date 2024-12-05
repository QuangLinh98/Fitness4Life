package tripplaner.notifyservice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tripplaner.notifyservice.helper.ApiResponse;
import tripplaner.notifyservice.models.Notify;
import tripplaner.notifyservice.service.NotifyService;

import java.util.List;

@RestController
@RequestMapping("/api/notify")
@RequiredArgsConstructor
public class PublicController {
    private final NotifyService notifyService;

    @GetMapping("/all")
    public ResponseEntity<?> getAllNotify() {
        try {
            List<Notify> notifies = notifyService.findAll();
            return ResponseEntity.status(200).body(ApiResponse
                    .success(notifies, "get notify successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse
                    .errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getNotifyById(@PathVariable Long id) {
        try {
            Notify notify = notifyService.findById(id);
            if (notify != null) {
                return ResponseEntity.status(200).body(ApiResponse
                        .success(notify, "get notify successfully"));
            } else {
                return ResponseEntity.status(404).body(ApiResponse
                        .notfound("notify not found"));
            }
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
        }
    }
}
