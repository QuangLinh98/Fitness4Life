package fpt.aptech.bookingservice.service;

import com.paypal.api.payments.*;
import com.paypal.base.rest.APIContext;
import com.paypal.base.rest.PayPalRESTException;
import fpt.aptech.bookingservice.dtos.MembershipSubscriptionDTO;
import fpt.aptech.bookingservice.dtos.UserDTO;
import fpt.aptech.bookingservice.eureka_client.UserEurekaClient;
import fpt.aptech.bookingservice.models.MembershipSubscription;
import fpt.aptech.bookingservice.models.PayMethodType;
import fpt.aptech.bookingservice.models.PayStatusType;
import fpt.aptech.bookingservice.models.WorkoutPackage;
import fpt.aptech.bookingservice.repository.MembershipSubscriptionRepository;
import fpt.aptech.bookingservice.repository.WorkoutPackageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PayPalService {
    private final APIContext apiContext;
    private final UserEurekaClient userEurekaClient;
    private final WorkoutPackageRepository workoutPackageRepository;
    private final MembershipSubscriptionRepository membershipRepository;

    /**
     * Tạo một đối tượng Payment mới để bắt đầu quy trình thanh toán với PayPal.
     * <p>
     * total Số tiền thanh toán
     * currency Đơn vị tiền tệ
     * method Phương thức thanh toán
     * intent Mục đích của thanh toán (e.g., sale, authorize)
     * description Mô tả về giao dịch
     * cancelUrl URL để chuyển hướng khi thanh toán bị hủy
     * successUrl URL để chuyển hướng khi thanh toán thành công
     *
     * @return Đối tượng Payment đã được tạo
     * @throws PayPalRESTException Nếu có lỗi trong quá trình tương tác với PayPal
     */

    public ResponseEntity<?> createPayment(@RequestBody MembershipSubscriptionDTO subscriptionDTO) {
        try {
            System.out.println("✅ Nhận được request từ Flutter: " + subscriptionDTO);
            System.out.println("📥 Giá trị TotalAmount nhận từ Frontend: " + subscriptionDTO.getTotalAmount());

            // Kiểm tra userId có tồn tại không
            UserDTO userExisting = userEurekaClient.getUserById(subscriptionDTO.getUserId());
            if (userExisting == null) {
                System.out.println("❌ User không tồn tại!");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "User not found"));
            }

            // Lấy gói tập theo ID
            WorkoutPackage packageExisting = workoutPackageRepository.findById(subscriptionDTO.getPackageId())
                    .orElseThrow(() -> new RuntimeException("Workout package not found"));

            Double totalAmount = subscriptionDTO.getTotalAmount(); // ✅ Lấy từ transactions.amount.total
            double finalAmount = (totalAmount != null && totalAmount > 0) ? totalAmount : packageExisting.getPrice();


            System.out.println("✅ Final Amount gửi đến PayPal: " + finalAmount);

            Amount amount = new Amount();
            amount.setCurrency(subscriptionDTO.getCurrency());
            amount.setTotal(String.format("%.2f", finalAmount));

            Transaction transaction = new Transaction();
            transaction.setDescription(subscriptionDTO.getDescription());
            transaction.setAmount(amount);

            List<Transaction> transactions = new ArrayList<>();
            transactions.add(transaction);

            Payer payer = new Payer();
            payer.setPaymentMethod(PayMethodType.PAYPAL.toString());

            Payment payment = new Payment();
            payment.setIntent(subscriptionDTO.getIntent());
            payment.setPayer(payer);
            payment.setTransactions(transactions);

            RedirectUrls redirectUrls = new RedirectUrls();
            redirectUrls.setCancelUrl(subscriptionDTO.getCancelUrl());
            redirectUrls.setReturnUrl(subscriptionDTO.getSuccessUrl());
            payment.setRedirectUrls(redirectUrls);

            System.out.println("✅ Gửi yêu cầu tạo thanh toán đến PayPal...");
            System.out.println("📤 Dữ liệu gửi lên PayPal: " + payment.toJSON());

            Payment createdPayment = payment.create(apiContext);

            if (createdPayment == null) {
                System.out.println("❌ PayPal không trả về phản hồi!");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "PayPal payment creation failed"));
            }

            System.out.println("✅ PayPal đã tạo thanh toán thành công: " + createdPayment.getId());

            // ✅ Tìm URL phê duyệt từ danh sách links của PayPal
            String approvalUrl = null;
            for (Links link : createdPayment.getLinks()) {
                if ("approval_url".equals(link.getRel())) {
                    approvalUrl = link.getHref();
                    break;
                }
            }

            // Nếu không tìm thấy URL, trả về lỗi
            if (approvalUrl == null) {
                System.out.println("❌ Không tìm thấy approval URL!");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(Map.of("error", "Không tìm thấy approval URL từ PayPal"));
            }

            // Lưu vào database
            MembershipSubscription membershipSubscription = MembershipSubscription.builder()
                    .packageId(subscriptionDTO.getPackageId())
                    .userId(subscriptionDTO.getUserId())
                    .fullName(userExisting.getFullName())
                    .buyDate(LocalDateTime.now())
                    .startDate(LocalDateTime.now().toLocalDate())
                    .endDate(LocalDateTime.now().plusMonths(packageExisting.getDurationMonth()).toLocalDate())
                    .payMethodType(PayMethodType.PAYPAL)
                    .payStatusType(PayStatusType.PENDING)
                    .packageName(packageExisting.getPackageName())
                    .description(subscriptionDTO.getDescription())
                    .totalAmount(finalAmount)
                    .paymentId(createdPayment.getId())
                    .build();

            membershipRepository.save(membershipSubscription);

            // ✅ Đảm bảo luôn trả về phản hồi cho Flutter
            return ResponseEntity.ok(Map.of("approvalUrl", approvalUrl));
        } catch (Exception e) {
            System.out.println("❌ Lỗi khi xử lý thanh toán: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }


    /**
     * Thực hiện thanh toán sau khi người dùng xác nhận thanh toán trên PayPal.
     * <p>
     * paymentId ID của giao dịch thanh toán
     * payerId ID của người thanh toán
     *
     * @return Đối tượng Payment đã được thực hiện
     * @throws PayPalRESTException Nếu có lỗi trong quá trình tương tác với PayPal
     */
    public Payment executePayment(String paymentId, String payerId) throws PayPalRESTException {

        // Tạo đối tượng Payment với ID thanh toán
        Payment payment = new Payment();
        payment.setId(paymentId);
        // Tạo đối tượng PaymentExecution và thiết lập ID người thanh toán
        PaymentExecution paymentExecution = new PaymentExecution();
        paymentExecution.setPayerId(payerId);
        // Thực hiện thanh toán trên PayPal
        Payment executedPayment = payment.execute(apiContext, paymentExecution);
        // Cập nhật trạng thái thanh toán sau khi thực hiện
        MembershipSubscription paymentMembership = membershipRepository.findByPaymentId(paymentId);
        if (paymentMembership != null) {
            paymentMembership.setPayerId(payerId);
            paymentMembership.setPayStatusType(PayStatusType.valueOf(PayStatusType.COMPLETED.toString()));
            // Cập nhật gói tập (packageId) cho user
            userEurekaClient.assignWorkoutPackage(paymentMembership.getUserId(), paymentMembership.getPackageId());
            membershipRepository.save(paymentMembership);
        }
        return executedPayment;
    }

    public MembershipSubscription getMembershippaymentId(String paymentId) {
        return membershipRepository.findByPaymentId(paymentId);
    }

    public MembershipSubscription getMembershipByUserId(long userId)  {
         var userExisting = membershipRepository.findMemberShipByUserId(userId);
         if (userExisting != null) {
             return membershipRepository.findMemberShipByUserId(userId);
         }
         else {
             throw new RuntimeException("Membership with userId " + userId + " not found");
         }
    }

}
