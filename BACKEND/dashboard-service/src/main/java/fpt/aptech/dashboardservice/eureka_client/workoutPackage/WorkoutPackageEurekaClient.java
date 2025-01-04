package fpt.aptech.dashboardservice.eureka_client.workoutPackage;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient("booking-service")
public interface WorkoutPackageEurekaClient {
    @GetMapping("/api/booking/package/{id}")
    WorkoutPackageDTO getWorkoutPackageById(@PathVariable int id , @RequestHeader("Authorization") String token); //token được truyền vào trong header để gửi đến booking service

    // Lấy danh sách WorkoutPackage theo danh sách ID
    @PostMapping("/api/booking/packages/by-ids")
    List<WorkoutPackageDTO> getWorkoutPackagesByIds(@RequestBody List<Integer> ids);
}
