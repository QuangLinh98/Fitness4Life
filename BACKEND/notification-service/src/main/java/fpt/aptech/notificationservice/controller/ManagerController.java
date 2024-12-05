package tripplaner.notifyservice.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tripplaner.notifyservice.helper.ApiResponse;
import tripplaner.notifyservice.models.Notify;
import tripplaner.notifyservice.service.NotifyService;

@RestController
@RequestMapping("/api/notify")
@RequiredArgsConstructor
public class ManagerController {
    private final NotifyService notifyService;

    @PostMapping("/create")
    public ResponseEntity<?> createNotify(@Valid @RequestBody Notify notify,
                                              BindingResult bindingResult) {
        try {
            if (bindingResult.hasErrors()) {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }

            Notify createNotify = notifyService.addNotify(notify);
            return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse
                    .created(createNotify, "create notify successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.errorServer("error server: " + ex.getMessage()));
        }
    }
}
