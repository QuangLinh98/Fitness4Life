package fpt.aptech.bookingservice.eureka_client;

import fpt.aptech.bookingservice.dtos.RoomDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "dashboard-service",url = "http://localhost:8081")
public interface RoomEurekaClient {
    @GetMapping("/api/dashboard/room/{id}")
    RoomDTO getRoomById(@PathVariable int id);

    @PutMapping("/api/dashboard/availableSeats/update/{id}")
    RoomDTO updateRoom(@PathVariable int id, @RequestBody RoomDTO roomDTO);
}
