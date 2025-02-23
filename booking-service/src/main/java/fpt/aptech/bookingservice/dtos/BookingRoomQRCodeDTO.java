package fpt.aptech.bookingservice.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BookingRoomQRCodeDTO {
    private int id;
    private String qrCodeUrl ;   // URL chứa mã QR code để check-in
}
