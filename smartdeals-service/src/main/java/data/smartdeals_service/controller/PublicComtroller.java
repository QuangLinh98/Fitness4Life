package data.smartdeals_service.controller;

import data.smartdeals_service.dto.user.UserDTO;
import data.smartdeals_service.eureka_client.ErurekaService;
import data.smartdeals_service.helpers.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/public")
@RequiredArgsConstructor
public class PublicComtroller {
    private final ErurekaService erurekaService;

    @GetMapping("/users/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        try {
            UserDTO userDTO = erurekaService.getUserById(id);
            if(userDTO == null){
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiResponse
                        .notfound("userDTO not found"));
            }
            return ResponseEntity.status(HttpStatus.OK).body(ApiResponse
                    .success(userDTO, "get userDTO successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiResponse
                    .errorServer("Unexpected error: " + ex.getMessage()));
        }
    }

    @GetMapping("/users")
    public ResponseEntity<?> getAllUser() {
        try {
            List<UserDTO> userDTO = erurekaService.getAllUser();

            return ResponseEntity.status(HttpStatus.OK).body(ApiResponse
                    .success(userDTO, "get userDTO successfully"));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiResponse
                    .errorServer("Unexpected error: " + ex.getMessage()));
        }
    }
}
