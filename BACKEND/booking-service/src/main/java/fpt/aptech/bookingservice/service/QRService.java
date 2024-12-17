package fpt.aptech.bookingservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.google.zxing.WriterException;
import fpt.aptech.bookingservice.dtos.ResponseQRCodeByBookingDTO;
import fpt.aptech.bookingservice.dtos.RoomDTO;
import fpt.aptech.bookingservice.eureka_client.RoomEurekaClient;
import fpt.aptech.bookingservice.helpers.QRCodeGenerator;
import fpt.aptech.bookingservice.models.BookingRoom;
import fpt.aptech.bookingservice.models.QRCode;
import fpt.aptech.bookingservice.models.QRCodeStatus;
import fpt.aptech.bookingservice.repository.BookingRoomRepository;
import fpt.aptech.bookingservice.repository.QRRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private static final String QR_CODE_DIRECTORY = "src/main/resources/static/qrcodes/";

    //Handle get QR by BookingId
    @Transactional(readOnly = true)
    public ResponseQRCodeByBookingDTO getQRByBookingId(int bookingId) {
        BookingRoom bookingRoom = bookingRoomRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking room not found"));
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

        // Kiểm tra StartTime và EndTime
        if (existingRoom.getStartTime() == null || existingRoom.getEndTime() == null) {
            throw new RuntimeException("StartTime or EndTime is not available for Room ID: " + bookingRoom.getRoomId());
        }
        BookingRoom savedBooking = bookingRoomRepository.save(bookingRoom);

        try {
            //Tạo mã RANDOM cho QR
            String checkInCode = UUID.randomUUID().toString();
            //Đường dẫn lưu file QR Code
            String qrFilePath = QR_CODE_DIRECTORY + checkInCode + ".jpg";

            // Tạo nội dung JSON theo table-like structure
            Map<String, Object> qrData = new HashMap<>();
            qrData.put("UserName", savedBooking.getUserName());
            qrData.put("RoomName", savedBooking.getRoomName());
            qrData.put("StartTime", existingRoom.getStartTime().toString());
            qrData.put("EndTime", existingRoom.getEndTime().toString());
            qrData.put("BookingDate", savedBooking.getBookingDate().toString());

            // Chuyển Map thành JSON string
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.enable(SerializationFeature.INDENT_OUTPUT);
            String bookingInfoJson = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(qrData);

            //Gọi hàm tạo mã QR
            QRCodeGenerator.generateQRCodeImage(bookingInfoJson, qrFilePath);

            //Tạo QR Code cho booking và lưu vào database
            QRCode qrCode = QRCode.builder()
                    .qrCodeUrl("http://localhost:8082/qrcodes/" + checkInCode + ".jpg")
                    .qrCodeStatus(QRCodeStatus.VALID)
                    .bookingRoom(savedBooking)
                    .build();
            //Cập nhật Booking Room với QR Code đã tạo
            savedBooking.setQrCode(qrCode);
            qrRepository.save(qrCode);
            bookingRoomRepository.save(savedBooking);
            return qrCode;
        } catch (IOException | WriterException e) {
            throw new RuntimeException("Failed to generate QR Code", e);
        }
    }

    //Xác thực mã QR
    @Transactional(noRollbackFor = RuntimeException.class)
    public Map<String, Object> validateQRCodeAndFetchBookingDetails(int qrCodeId) {
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
