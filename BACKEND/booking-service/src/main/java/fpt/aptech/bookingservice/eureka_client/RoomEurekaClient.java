package fpt.aptech.bookingservice.eureka_client;

import fpt.aptech.bookingservice.dtos.RoomDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient("dashboard-service")
public interface RoomEurekaClient {
    @GetMapping("/api/dashboard/room/{id}")
    RoomDTO getRoomById(@PathVariable int id);

    @PutMapping("/api/dashboard/availableSeats/update/{id}")
    RoomDTO updateRoom(@PathVariable int id, @RequestBody RoomDTO roomDTO);
}
