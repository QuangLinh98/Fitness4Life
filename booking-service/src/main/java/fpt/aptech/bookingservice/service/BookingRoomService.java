package fpt.aptech.bookingservice.service;

import fpt.aptech.bookingservice.dtos.*;
import fpt.aptech.bookingservice.eureka_client.RoomEurekaClient;
import fpt.aptech.bookingservice.eureka_client.UserEurekaClient;
import fpt.aptech.bookingservice.helpers.QRCodeGenerator;
import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.models.BookingStatus;
import fpt.aptech.bookingservice.repository.BookingRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class BookingRoomService {
    private final BookingRoomRepository bookingRoomRepository;
    private final UserEurekaClient userEurekaClient;
    private final RoomEurekaClient roomEurekaClient;


    //Handle get all data
    public List<BookingRoom> getAllBookingRoom() {
        return bookingRoomRepository.findAll();
    }

    //Handle get one BookRoom
    public BookingRoom getBookRoomById(int id) {
        return bookingRoomRepository.findById(id).get();
    }

    //Handle get BookRoom By UserId
    public List <BookingRoom> getBookRoomByUserId(int userId)
    {
        //Kiểm tra userId có tồn tại hay không
        UserDTO existingUser = userEurekaClient.getUserById(userId);

        if (existingUser == null) {
            throw new RuntimeException("User not found");
        }

         List<BookingRoom> bookingRooms = bookingRoomRepository.findByUserId(userId);

        if (bookingRooms.isEmpty()) {
            throw new RuntimeException("Booking room not found for user " + userId);
        }
        return bookingRooms;
    }

    //Handle booking room
    public BookingRoom saveBookRoom(BooKingRoomDTO booKRoomDTO) {
        //Kiểm tra room có tồn tại hay không
        RoomDTO roomExiting = roomEurekaClient.getRoomById(booKRoomDTO.getRoomId());
        if (roomExiting == null) {
            throw new RuntimeException("Room Not Found");
        }
        //Kiểm tra xem thời gian hiện tại có nằm trong khoảng thời gian học hay không , không thể booking nếu lớp học đã bắt đầu
        LocalTime currentTime = LocalTime.now();
        if (currentTime.isAfter(roomExiting.getStartTime()) && currentTime.isBefore(roomExiting.getEndTime())) {
            throw new RuntimeException("Can not Book Room During Class Hours");
        }

        //Kiểm tra room còn AvailableSeats trống để booking hay không
        if (roomExiting.getAvailableSeats() == roomExiting.getCapacity()) {
            throw new RuntimeException("The Class Room Is Full");
        }

        //Kiểm tra user có tồn tại hay không
        UserDTO userExisting = userEurekaClient.getUserById(booKRoomDTO.getUserId());
        if (userExisting == null) {
            throw new RuntimeException("User Not Found");
        }

        //kiểm danh sách lịch booking của user , user không thể booking 2 lớp học có cùng startTime với trạng thái booking là Confirmed
        List<BookingRoom> existingBooking = bookingRoomRepository.findByUserIdAndStatus(
                booKRoomDTO.getUserId(),
                BookingStatus.CONFIRMED
        );

        for (BookingRoom bookingRoom : existingBooking) {
            RoomDTO bookedRoom = roomEurekaClient.getRoomById(bookingRoom.getRoomId());
            if (bookedRoom.getStartTime().equals(roomExiting.getStartTime()) &&
                    bookedRoom.getEndTime().equals(roomExiting.getEndTime())) {
                throw new RuntimeException(" You Already Have A Confirmed Booking For This Time.");
            }
        }
        BookingRoom newBooking = BookingRoom.builder()
                .userId(booKRoomDTO.getUserId())
                .userName(userExisting.getFullName())    //Lấy name từ userDTO
                .roomId(booKRoomDTO.getRoomId())
                .roomName(roomExiting.getRoomName())     //Lấy name từ roomDTO
                .bookingDate(LocalDateTime.now())
                .status(BookingStatus.CONFIRMED)
                .createAt(LocalDateTime.now())
                .build();

        //Update số lượng ghế khả dụng trong Room
        roomExiting.setAvailableSeats(roomExiting.getAvailableSeats() + 1);
        roomEurekaClient.updateRoom(roomExiting.getId(), roomExiting);
        bookingRoomRepository.save(newBooking);
        return newBooking;
    }

    //Handle cancel booking room
    public void cancelBookingRoom(int id) {
        BookingRoom bookingRoom = bookingRoomRepository.findById(id).orElseThrow(() -> new RuntimeException("BookingRoomNotFound"));
        //Chỉ cho phép hủy nếu trạng thái booking không phải là calceled
        if (bookingRoom.getStatus() != BookingStatus.CANCELED) {
            bookingRoom.setStatus(BookingStatus.CANCELED);
            bookingRoomRepository.save(bookingRoom);
            RoomDTO roomExiting = roomEurekaClient.getRoomById(bookingRoom.getRoomId());
            roomExiting.setAvailableSeats(roomExiting.getAvailableSeats() - 1);  //Update lại ghế khi user hủy booking
            roomEurekaClient.updateRoom(roomExiting.getId(), roomExiting);
        }
    }
}
