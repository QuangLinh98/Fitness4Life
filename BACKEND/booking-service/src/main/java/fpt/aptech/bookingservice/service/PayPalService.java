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
//    public Payment createPayment(MembershipSubscriptionDTO subscriptionDTO) throws PayPalRESTException {
//
//        System.out.println("✅ Nhận được request từ Flutter: " + subscriptionDTO);
//
//        //Kiểm tra sự tôn tại của userId có hợp lệ hay không
//        UserDTO userExisting = userEurekaClient.getUserById(subscriptionDTO.getUserId());
//        if (userExisting == null) {
//            throw new PayPalRESTException("User not found");
//        }
//
//        WorkoutPackage packageExisting = workoutPackageRepository.findById(subscriptionDTO.getPackageId())
//                .orElseThrow(() -> new RuntimeException("Workout package not found"));
//
//        // Khởi tạo giá trị totalAmount ban đầu từ price của package
//        double initialAmount = packageExisting.getPrice();
//
//        // Định dạng lại price (initialAmount) để đảm bảo là một số thập phân với 2 chữ số
//        String formattedPrice = String.format("%.2f", initialAmount);
//        double formattedInitialAmount = Double.parseDouble(formattedPrice);
//
//        System.out.println("Formatted Init Price: " + formattedInitialAmount);
//
//        // Kiểm tra giá trị totalAmount được gửi từ frontend
//        double finalAmount = subscriptionDTO.getTotalAmount();
//
//        System.out.println("Final Amount : " + finalAmount);
//
//        // Nếu totalAmount <= 0, sử dụng giá trị price của package để tính toán
//        if (finalAmount <= 0) {
//            finalAmount = initialAmount;
//        }
//
//        // Định dạng finalAmount thành 2 chữ số thập phân
//        String formattedAmount = String.format("%.2f", finalAmount);
//        System.out.println("Final Amount after discount: " + formattedAmount);
//
//        Amount amount = new Amount();
//        amount.setCurrency(subscriptionDTO.getCurrency());
//        amount.setTotal(String.valueOf(finalAmount));
//
//        // Tạo đối tượng Transaction và thiết lập mô tả và số tiền
//        Transaction transaction = new Transaction();
//        transaction.setDescription(subscriptionDTO.getDescription());
//        transaction.setAmount(amount);
//
//        // Tạo danh sách các giao dịch và thêm giao dịch vừa tạo vào danh sách
//        List<Transaction> transactions = new ArrayList<>();
//        transactions.add(transaction);
//
//        // Tạo đối tượng Payer và thiết lập phương thức thanh toán
//        Payer payer = new Payer();
//        payer.setPaymentMethod(PayMethodType.PAYPAL.toString());
//
//        // Tạo đối tượng Payment và thiết lập các thuộc tính liên quan
//        Payment payment = new Payment();
//        payment.setIntent(subscriptionDTO.getIntent());
//        payment.setPayer(payer);
//        payment.setTransactions(transactions);
//
//        System.out.println("Payment Request JSON: " + payment.toJSON());  // Log toàn bộ JSON của payment
//
//
//        // Tạo đối tượng RedirectUrls và thiết lập các URL chuyển hướng
//        RedirectUrls redirectUrls = new RedirectUrls();
//        redirectUrls.setCancelUrl(subscriptionDTO.getCancelUrl());
//        redirectUrls.setReturnUrl(subscriptionDTO.getSuccessUrl());
//        payment.setRedirectUrls(redirectUrls);
//
//        System.out.println("✅ Gửi yêu cầu tạo thanh toán đến PayPal...");
//
//        // Tạo một Payment mới trên PayPal
//        Payment createdPayment = payment.create(apiContext);
//
//        // Lấy ngày thanh toán là ngày hiện tại
//        LocalDateTime currentDateTime = LocalDateTime.now();
//
//        // Tính toán ngày kết thúc (thêm durationMonth vào ngày bắt đầu)
//        LocalDateTime endDate = currentDateTime.plusMonths(packageExisting.getDurationMonth());
//
//        // Lưu thông tin thanh toán vào cơ sở dữ liệu
//        MembershipSubscription membershipSubscription = MembershipSubscription.builder()
//                .packageId(subscriptionDTO.getPackageId())
//                .userId(subscriptionDTO.getUserId())
//                .fullName(userExisting.getFullName())
//                .buyDate(currentDateTime)   //Ngày mua sẽ là ngày thanh toán
//                .startDate(currentDateTime.toLocalDate())  // Start date là ngày thanh toán thành công
//                .endDate(endDate.toLocalDate())    // End date là ngày tính toán dựa trên duration
//                .payMethodType(PayMethodType.valueOf(PayMethodType.PAYPAL.toString()))
//                .payStatusType(PayStatusType.valueOf(PayStatusType.PENDING.toString()))
//                .packageName(packageExisting.getPackageName())
//                .description(subscriptionDTO.getDescription())
//                .totalAmount(finalAmount)
//                .paymentId(createdPayment.getId())
//                .build();
//        membershipRepository.save(membershipSubscription);
//        return createdPayment;
//    }

    public ResponseEntity<?> createPayment(@RequestBody MembershipSubscriptionDTO subscriptionDTO) {
        try {
            System.out.println("✅ Nhận được request từ Flutter: " + subscriptionDTO);

            // Kiểm tra userId có tồn tại không
            UserDTO userExisting = userEurekaClient.getUserById(subscriptionDTO.getUserId());
            if (userExisting == null) {
                System.out.println("❌ User không tồn tại!");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", "User not found"));
            }

            // Lấy gói tập theo ID
            WorkoutPackage packageExisting = workoutPackageRepository.findById(subscriptionDTO.getPackageId())
                    .orElseThrow(() -> new RuntimeException("Workout package not found"));

            double finalAmount = packageExisting.getPrice();
            if (subscriptionDTO.getTotalAmount() > 0) {
                finalAmount = subscriptionDTO.getTotalAmount();
            }

            System.out.println("✅ Final Amount: " + finalAmount);

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

            // 🛑 Cẩn thận! Lệnh này có thể bị lỗi nếu PayPal API không phản hồi
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
