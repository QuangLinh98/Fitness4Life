package fpt.aptech.notificationservice.eureka_client;


import fpt.aptech.notificationservice.dtos.UserDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient("user-service")
public interface UserEurekaClient {
    @GetMapping("api/users/manager/users/{id}")
    UserDTO getUserById(@PathVariable long id); // @RequestHeader("Authorization") String token

}
