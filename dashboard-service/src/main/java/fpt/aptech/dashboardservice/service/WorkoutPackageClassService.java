package fpt.aptech.dashboardservice.service;

import fpt.aptech.dashboardservice.eureka_client.workoutPackage.WorkoutPackageDTO;
import fpt.aptech.dashboardservice.eureka_client.workoutPackage.WorkoutPackageEurekaClient;
import fpt.aptech.dashboardservice.models.Room;
import fpt.aptech.dashboardservice.models.WorkoutPackageRoom;
import fpt.aptech.dashboardservice.repository.RoomRepository;
import fpt.aptech.dashboardservice.repository.WorkoutPackageRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WorkoutPackageClassService {
    private final WorkoutPackageRoomRepository workoutPackageClassRepository;
    private final WorkoutPackageEurekaClient packageEurekaClient;
    private final RoomRepository roomRepository;

    //Handle add a new Room into WorkoutPackage , token được truyền vào trong header để gửi đến booking service
    @Transactional
    public WorkoutPackageRoom addRoomToPackage(int roomId, int workoutPackageId , String token) {
        //Kiểm tra workout package có tồn tại hay không
        WorkoutPackageDTO existingPackage = packageEurekaClient.getWorkoutPackageById(workoutPackageId, token);
        if (existingPackage == null) {
            throw new RuntimeException(" Workout package not found");
        }

        //Kiểm tra room có tồn tại hay không
        Room existingRoom = roomRepository.findById(roomId).orElseThrow(() -> new RuntimeException(" Room not found"));

        //Kiểm tra nếu quan hệ đã tồn tại
        boolean exists = workoutPackageClassRepository.existsByWorkoutPackageIdAndRoomId(workoutPackageId, roomId);
        if (exists) {
            throw new RuntimeException("Room with id: " + roomId + " is already assigned to package with id: " + workoutPackageId);
        }

        // Tạo mới quan hệ giữa WorkoutPackage và Room
        WorkoutPackageRoom workoutPackageRoom = new WorkoutPackageRoom();
        workoutPackageRoom.setWorkoutPackageId(workoutPackageId);
        workoutPackageRoom.setRoomId(roomId);

        workoutPackageClassRepository.save(workoutPackageRoom);
        return workoutPackageRoom;
    }

    //Handle get all Room by workoutPackageId
    @Transactional(readOnly = true)
    public List<Room> getRoomsByWorkoutPackage(int workoutPackageId, String token) {
        //Kiểm tra workout package có tồn tại hay không
        WorkoutPackageDTO existingPackage = packageEurekaClient.getWorkoutPackageById(workoutPackageId, token);
        if (existingPackage == null) {
            throw new RuntimeException("Workout package not found");
        }

        // Lấy danh sách ID của các lớp học liên kết với WorkoutPackage
        List<Integer> roomIds = workoutPackageClassRepository.findRoomIdsByWorkoutPackageId(workoutPackageId);

        return roomRepository.findAllById(roomIds);
    }

    //Handle get all workoutPackageId by Room
    @Transactional(readOnly = true)
    public List<WorkoutPackageDTO> getWorkoutPackagesByRoom(int roomId) {
        // Kiểm tra xem Class có tồn tại không
        roomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + roomId));

        // Lấy danh sách ID của các gói tập liên kết với Class
        List<Integer> packageIds = workoutPackageClassRepository.findWorkoutPackageIdsByRoomId(roomId);

        // Truy vấn danh sách gói tập từ workoutPackageRepository
        return packageEurekaClient.getWorkoutPackagesByIds(packageIds);
    }

    //Handle remove Room in WorkoutPackage
    @Transactional
    public void removeRoomFromPackage(int packageId, int roomId) {
        // Kiểm tra nếu quan hệ có tồn tại
        boolean exists = workoutPackageClassRepository.existsByWorkoutPackageIdAndRoomId(packageId, roomId);
        if (!exists) {
            throw new RuntimeException("Room with id: " + roomId + " is not assigned to package with id: " + packageId);
        }

        // Xóa quan hệ giữa WorkoutPackage và Class
        workoutPackageClassRepository.deleteByWorkoutPackageIdAndRoomId(packageId, roomId);
    }
}