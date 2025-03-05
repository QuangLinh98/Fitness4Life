package data.smartdeals_service.eureka_client;


import data.smartdeals_service.dto.user.UserDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@FeignClient(name = "user-service")
public interface ErurekaService {
    @GetMapping("/api/users/manager/users/{id}")
    UserDTO getUserById(@PathVariable Long id);

    @GetMapping("/api/users/manager/all")
    List<UserDTO> getAllUser();

    @GetMapping("/api/users/get-by-email")
    UserDTO getUserByEmail(@RequestParam String email);
}

