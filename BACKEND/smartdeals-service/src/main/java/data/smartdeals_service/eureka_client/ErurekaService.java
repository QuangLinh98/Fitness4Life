package data.smartdeals_service.eureka_client;


import data.smartdeals_service.dto.user.UserDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@FeignClient(name = "user-service")
public interface ErurekaService {
    @GetMapping("/api/users/manager/users/{id}")
    UserDTO getUserById(@PathVariable Long id);

    @GetMapping("/api/users/manager/all")
    List<UserDTO> getAllUser();
}

