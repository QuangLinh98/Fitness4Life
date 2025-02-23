package fpt.aptech.bookingservice.repository;

import fpt.aptech.bookingservice.dtos.ResponseQRCodeByBookingDTO;
import fpt.aptech.bookingservice.models.QRCode;
import fpt.aptech.bookingservice.models.QRCodeStatus;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;

public interface QRRepository extends JpaRepository<QRCode, Integer> {
    // Truy vấn xóa theo trạng thái và thời gian tạo
    @Modifying
    @Transactional
    @Query("DELETE FROM QRCode q WHERE q.qrCodeStatus = :status AND q.createdAt < :beforeTime")
    void deleteByQrCodeStatusAndCreatedAtBefore(@Param("status") QRCodeStatus status, @Param("beforeTime") LocalDateTime beforeTime);

    @Query("SELECT new fpt.aptech.bookingservice.dtos.ResponseQRCodeByBookingDTO(q.bookingRoom.id, q.qrCodeUrl) " +
            "FROM QRCode q WHERE q.bookingRoom.id = :bookingRoomId")
    ResponseQRCodeByBookingDTO findQRCodeByBookingRoomId(@Param("bookingRoomId") int bookingRoomId);

}
