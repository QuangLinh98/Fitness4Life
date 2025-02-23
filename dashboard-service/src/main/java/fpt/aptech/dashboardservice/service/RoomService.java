package fpt.aptech.dashboardservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import fpt.aptech.dashboardservice.dtos.AvailableSeatsRoomUpdateDTO;
import fpt.aptech.dashboardservice.dtos.RoomDTO;
import fpt.aptech.dashboardservice.models.Branch;
import fpt.aptech.dashboardservice.models.Club;
import fpt.aptech.dashboardservice.models.Room;
import fpt.aptech.dashboardservice.models.Trainer;
import fpt.aptech.dashboardservice.repository.BranchRepository;
import fpt.aptech.dashboardservice.repository.ClubRepository;
import fpt.aptech.dashboardservice.repository.RoomRepository;
import fpt.aptech.dashboardservice.repository.TrainerRepository;
import fpt.aptech.dashboardservice.service.SlugUtil.Slug;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RoomService {
    private final RoomRepository roomRepository;
    private final ClubRepository clubRepository;
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
        Club clubExisting = clubRepository.findById(roomDTO.getClub()).orElseThrow(() -> new RuntimeException("ClubNotFound"));
        Trainer trainerExisting = trainerRepository.findById(roomDTO.getTrainer()).orElseThrow(() -> new RuntimeException("TrainerNotFound"));

        Room room = Room.builder()
                .roomName(roomDTO.getRoomName())
                .capacity(roomDTO.getCapacity())
                .facilities(roomDTO.getFacilities())
                .status(true)
                .startTime(roomDTO.getStartTime())
                .endTime(roomDTO.getEndTime())
                .createdAt(LocalDateTime.now())
                .build();
        room.setClub(clubExisting);
        room.setTrainer(trainerExisting);

        //Lưu data để lấy id
        room = roomRepository.save(room);
        String slug = Slug.generateSlug(room.getRoomName(), room.getId());
        room.setSlug(slug);
        return roomRepository.save(room);
    }

    //Handle update room
    public Room updateRoom(int id, RoomDTO roomDTO) {
        Room roomExisting = roomRepository.findById(id).orElseThrow(() -> new RuntimeException("RoomNotFound"));
        Club clubExisting = clubRepository.findById(roomDTO.getClub()).orElseThrow(() -> new RuntimeException("ClubNotFound"));
        Trainer trainerExisting = trainerRepository.findById(roomDTO.getTrainer()).orElseThrow(() -> new RuntimeException("TrainerNotFound"));

        roomExisting.setRoomName(roomDTO.getRoomName());
        roomExisting.setCapacity(roomDTO.getCapacity());
        roomExisting.setFacilities(roomDTO.getFacilities());
        roomExisting.setStatus(roomDTO.isStatus());
        roomExisting.setStartTime(roomDTO.getStartTime());
        roomExisting.setEndTime(roomDTO.getEndTime());
        roomExisting.setUpdatedAt(LocalDateTime.now());
        roomExisting.setClub(clubExisting);
        roomExisting.setTrainer(trainerExisting);

        String slug = Slug.generateSlug(roomExisting.getRoomName(), roomExisting.getId());
        roomExisting.setSlug(slug);

        return roomRepository.save(roomExisting);
    }

    //Phương thức update availableSeats của room
    public Room updateAvailableSeatsRoom(int id, AvailableSeatsRoomUpdateDTO availableSeatsDTO) {
        Room roomExisting = roomRepository.findById(id).orElseThrow(() -> new RuntimeException("RoomNotFound"));
        roomExisting.setAvailableSeats(availableSeatsDTO.getAvailableSeats());
        return roomRepository.save(roomExisting);
    }

    //Handle delete room
    public void deleteRoom(int id) {
        Room room = roomRepository.findById(id).orElseThrow(() -> new RuntimeException("RoomNotFound"));
         roomRepository.delete(room);
    }

}
