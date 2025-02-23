package fpt.aptech.bookingservice.dtos;

import lombok.Data;

@Data
public class ResponseQRCodeByBookingDTO {
       private int bookingRoom;
       private String qrCodeUrl;

    public ResponseQRCodeByBookingDTO(int bookingRoom, String qrCodeUrl) {
        this.bookingRoom = bookingRoom;
        this.qrCodeUrl = qrCodeUrl;
    }
}
