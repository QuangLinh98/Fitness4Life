package fpt.aptech.bookingservice.dtos;

import fpt.aptech.bookingservice.models.PackageName;
import fpt.aptech.bookingservice.models.PayMethodType;
import fpt.aptech.bookingservice.models.PayStatusType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class MembershipSubscriptionDTO {
    private long userId;
    private int packageId;
    private String description;   // Mô tả chi tiết về booking
    private LocalDateTime buyDate;  //Ngày đăng ký thẻ thành viên
    private String successUrl;
    private String cancelUrl;
    private LocalDate startDate;    //Ngày bắt đầu
    private LocalDate endDate;      //Ngày kết thúc
    private double totalAmount;     // Tổng số tiền cần thanh toán cho booking
    private String currency;     //Loại tiền tệ
    private String intent;
    private PackageName packageName;   // Tên membership
}
