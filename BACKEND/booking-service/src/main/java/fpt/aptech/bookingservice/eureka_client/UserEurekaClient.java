package fpt.aptech.bookingservice.eureka_client;

import fpt.aptech.bookingservice.dtos.UserDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient("user-service")
public interface UserEurekaClient {
    @GetMapping("api/users/manager/users/{id}")
    UserDTO getUserById(@PathVariable long id);
}
