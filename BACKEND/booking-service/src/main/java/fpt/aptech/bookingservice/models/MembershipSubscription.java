package fpt.aptech.bookingservice.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "membership_subcriptions")
public class MembershipSubcription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private long userId;
    private int packageId;
    private String paymentId;    // Mã giao dịch thanh toán
    private String payerId;     //Mã của người thanh toán
    private String description;   // Mô tả chi tiết về booking
    private LocalDateTime buyDate;
    private double totalAmout;     // Tổng số tiền cần thanh toán cho booking
    @Enumerated(EnumType.STRING)
    private PayMethodType payMethodType;    // Phương thức thanh toán

    @Enumerated(EnumType.STRING)
    private PayStatusType payStatusType;   // Trạng thái thanh toán
}
