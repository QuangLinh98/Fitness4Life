package fpt.aptech.dashboardservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.dashboardservice.dtos.RoomDTO;
import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.Room;
import fpt.aptech.dashboardservice.models.Trainer;
import fpt.aptech.dashboardservice.repository.BranchRepository;
import fpt.aptech.dashboardservice.repository.RoomRepository;
import fpt.aptech.dashboardservice.repository.TrainerRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RoomService {
    private final RoomRepository roomRepository;
    private final BranchRepository branchRepository;
    private final TrainerRepository trainerRepository;

    private final ObjectMapper objectMapper;

    //Handle get all data
    public List<Room> getAllRoom() {
        return roomRepository.findAll();
    }

    //Handle get one room
    public Room getRoomById(int id) {
        return roomRepository.findById(id).orElse(null);
    }

    //Handle create a new room
    public Room addRoom(RoomDTO roomDTO) {
        Branch branchExisting = branchRepository.findById(roomDTO.getBranch()).orElseThrow(() -> new RuntimeException("BranchNotFound"));
        Trainer trainerExisting = trainerRepository.findById(roomDTO.getTrainer()).orElseThrow(() -> new RuntimeException("TrainerNotFound"));
        Room room = Room.builder()
                .roomName(roomDTO.getRoomName())
                .capacity(roomDTO.getCapacity())
                .facilities(roomDTO.getFacilities())
                .status(true)
                .createdAt(LocalDateTime.now())
                .build();
        room.setBranch(branchExisting);
        room.setTrainer(trainerExisting);
        return roomRepository.save(room);
    }

    //Handle update room
    public Room updateRoom(int id, RoomDTO roomDTO) {
        Room roomExisting = roomRepository.findById(id).orElseThrow(() -> new RuntimeException("RoomNotFound"));
        Branch branchExisting = branchRepository.findById(roomDTO.getBranch()).orElseThrow(() -> new RuntimeException("BranchNotFound"));
        Trainer trainerExisting = trainerRepository.findById(roomDTO.getTrainer()).orElseThrow(() -> new RuntimeException("TrainerNotFound"));

        roomExisting.setRoomName(roomDTO.getRoomName());
        roomExisting.setCapacity(roomDTO.getCapacity());
        roomExisting.setFacilities(roomDTO.getFacilities());
        roomExisting.setStatus(roomDTO.isStatus());
        roomExisting.setUpdatedAt(LocalDateTime.now());
        roomExisting.setBranch(branchExisting);
        roomExisting.setTrainer(trainerExisting);

        return roomRepository.save(roomExisting);
    }

    //Handle delete room
    public void deleteRoom(int id) {
        Room room = roomRepository.findById(id).orElseThrow(() -> new RuntimeException("RoomNotFound"));
         roomRepository.delete(room);
    }

}
