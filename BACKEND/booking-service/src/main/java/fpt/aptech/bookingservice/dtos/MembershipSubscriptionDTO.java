package fpt.aptech.bookingservice.dtos;

import com.fasterxml.jackson.annotation.JsonProperty;
import fpt.aptech.bookingservice.models.PackageName;
import fpt.aptech.bookingservice.models.PayMethodType;
import fpt.aptech.bookingservice.models.PayStatusType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
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

//    @JsonProperty("totalAmount")
//    private Double totalAmount;     // Tổng số tiền cần thanh toán cho booking
    private String currency;     //Loại tiền tệ
    private String intent;
    private PackageName packageName;   // Tên membership

    @JsonProperty("transactions") // ✅ Lấy danh sách transactions từ JSON
    private List<TransactionDTO> transactions;

    // ✅ Sửa: Lấy totalAmount từ transactions.amount.total
    public Double getTotalAmount() {
        if (transactions != null && !transactions.isEmpty() && transactions.get(0).getAmount() != null) {
            return transactions.get(0).getAmount().getTotal();
        }
        return null; // ✅ Trả về null nếu không có giá trị
    }
}
