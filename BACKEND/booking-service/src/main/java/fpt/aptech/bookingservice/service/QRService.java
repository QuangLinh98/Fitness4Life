package fpt.aptech.bookingservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.google.zxing.WriterException;
import fpt.aptech.bookingservice.dtos.ResponseQRCodeByBookingDTO;
import fpt.aptech.bookingservice.dtos.RoomDTO;
import fpt.aptech.bookingservice.eureka_client.RoomEurekaClient;
import fpt.aptech.bookingservice.helpers.FileUpload;
import fpt.aptech.bookingservice.helpers.QRCodeGenerator;
import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.models.QRCode;
import fpt.aptech.bookingservice.models.QRCodeStatus;
import fpt.aptech.bookingservice.repository.BookingRoomRepository;
import fpt.aptech.bookingservice.repository.QRRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class QRService {
    private final QRRepository qrRepository;
    private final BookingRoomRepository bookingRoomRepository;
    private final RoomEurekaClient roomEurekaClient;
    private static final String QR_CODE_DIRECTORY = "uploads/qrCodeImages/";

    //Handle get QR by BookingId
    @Transactional(readOnly = true)
    public ResponseQRCodeByBookingDTO getQRByBookingId(int bookingId) {
        BookingRoom bookingRoom = bookingRoomRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException(" Booking room not found"));
        System.out.println("Booking ROom result: " + bookingRoom.getId());
        ResponseQRCodeByBookingDTO qrCode = qrRepository.findQRCodeByBookingRoomId(bookingId);
        System.out.println("QR Code result: " + qrCode);
        return qrCode;
    }

    //Handle create qrCode when booking successfully
    @Transactional
    public QRCode createBookingWithQRCode(BookingRoom bookingRoom) {

        RoomDTO existingRoom = roomEurekaClient.getRoomById(bookingRoom.getRoomId());
        if (existingRoom == null) {
            throw new RuntimeException("Room not found with ID: " + bookingRoom.getRoomId());
        }

        BookingRoom savedBooking = bookingRoomRepository.save(bookingRoom);

        try {
            // Lấy địa chỉ IP cục bộ (thay đổi 'localhost' thành địa chỉ IP)
            String localIpAddress = "192.168.1.45"; // Thay bằng địa chỉ IP thực tế của máy

            // Tạo mã RANDOM cho QR
            String checkInCode = UUID.randomUUID().toString();

            // Tạo đối tượng QRCode trước để lấy qrId
            QRCode qrCode = QRCode.builder()
                    .qrCodeUrl("http://" + localIpAddress + ":8082/uploads/qrCodeImages/" + checkInCode + ".jpg")
                    .qrCodeStatus(QRCodeStatus.VALID)
                    .bookingRoom(savedBooking)
                    .build();

            // Lưu QRCode vào database để lấy qrId
            qrRepository.save(qrCode);

            // Tạo URL API chứa qrId
            String apiUrl = String.format("http://%s:9000/api/booking/qrCode/validate?qrCodeId=%d",localIpAddress,qrCode.getId());

            File directory = new File(QR_CODE_DIRECTORY);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            // Gọi hàm tạo mã QR với URL API
            String qrFilePath = QR_CODE_DIRECTORY + checkInCode + ".jpg";
            QRCodeGenerator.generateQRCodeImage(apiUrl, qrFilePath);

            // Cập nhật đường dẫn vào QRCode và BookingRoom
            qrCode.setQrCodeUrl("http://"+ localIpAddress +":8082/uploads/qrCodeImages/" + checkInCode + ".jpg");
            qrRepository.save(qrCode);
            savedBooking.setQrCode(qrCode);

            bookingRoomRepository.save(savedBooking);

            return qrCode;

        } catch (IOException | WriterException e) {
            throw new RuntimeException("Failed to generate QR Code", e);
        }
    }


    //Xác thực mã QR
    @Transactional(noRollbackFor = RuntimeException.class)
    public Map<String, Object> validateQRCodeAndFetchBookingDetails(int qrCodeId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        System.out.println("Authentication at start: " + authentication);

        QRCode qrCode = qrRepository.findById(qrCodeId).orElseThrow(() -> new RuntimeException(" QR Code not found"));
        //Kiểm tra trạng thái mã QR
        if (QRCodeStatus.USED.equals(qrCode.getQrCodeStatus())) {
            throw new RuntimeException(" Validation failed: Used QR Code");
        }

        // Lấy thông tin BookingRoom liên kết với QR Code
        BookingRoom bookingRoom = qrCode.getBookingRoom();
        if (bookingRoom == null) {
            throw new RuntimeException("Validation failed: BookingRoom not found.");
        }

        //Kiểm tra thời gian hết hạn của mã QR (room endTime)
        LocalTime currentTime = LocalTime.now();
        RoomDTO roomDetails  = roomEurekaClient.getRoomById(bookingRoom.getRoomId());
        if (currentTime.isAfter(roomDetails.getEndTime())){
            qrCode.setQrCodeStatus(QRCodeStatus.EXPIRED);  //Cập nhật trạng thái
            qrRepository.save(qrCode);
            throw new RuntimeException("Validation failed: QR Code has expired.");
        }

        //Tạo map để trả về thông tin Booking Room và Trạng thái mã QR
        Map<String, Object> response  = new HashMap<>();
        response.put("QRCodeStatus", qrCode.getQrCodeStatus());
        response.put("BookingDetails", Map.of(
                "UserName",bookingRoom.getUserName(),
                "RoomName",bookingRoom.getRoomName(),
                "StartTime",bookingRoom.getBookingDate().toLocalTime(),
                "EndTime",bookingRoom.getBookingDate().toLocalTime().plusMinutes(30)
        ));

        //Cập nhật trạng thái mã QR
        qrCode.setQrCodeStatus(QRCodeStatus.USED);
        qrRepository.save(qrCode);
        return response;
    }

    @Scheduled(cron = "0 0 1 * * ?") // Chạy mỗi ngày lúc 0 giờ sáng
    public void cleanUpExpiredQRCodes() {
        qrRepository.deleteByQrCodeStatusAndCreatedAtBefore(QRCodeStatus.EXPIRED, LocalDateTime.now().minusHours(1));
    }
}
