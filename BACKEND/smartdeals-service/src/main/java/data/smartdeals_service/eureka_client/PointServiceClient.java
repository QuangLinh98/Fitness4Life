package data.smartdeals_service.eureka_client;

import data.smartdeals_service.dto.user.UserPoinDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "fitnessgoal-service")
public interface PointServiceClient {
    @PostMapping("/api/goal/approvePoint/{userId}")
    UserPoinDTO approvePoint(@PathVariable Long userId, @RequestParam int point);
}

