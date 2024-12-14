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
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
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
    public Payment createPayment(MembershipSubscriptionDTO subscriptionDTO) throws PayPalRESTException {
        //Kiểm tra sự tôn tại của userId có hợp lệ hay không
        UserDTO userExisting = userEurekaClient.getUserById(subscriptionDTO.getUserId());
        if (userExisting == null) {
            throw new PayPalRESTException("User not found");
        }

        WorkoutPackage packageExisting = workoutPackageRepository.findById(subscriptionDTO.getPackageId())
                .orElseThrow(() -> new RuntimeException("Workout package not found"));

        // Tạo đối tượng Amount và thiết lập tiền tệ và tổng số tiền
        Amount amount = new Amount();
        amount.setCurrency(subscriptionDTO.getCurrency());
        amount.setTotal(String.format("%.2f", subscriptionDTO.getTotalAmount()));   //Format cho nó chỉ lấy 2 chữ số phía sau

        // Tạo đối tượng Transaction và thiết lập mô tả và số tiền
        Transaction transaction = new Transaction();
        transaction.setDescription(subscriptionDTO.getDescription());
        transaction.setAmount(amount);

        // Tạo danh sách các giao dịch và thêm giao dịch vừa tạo vào danh sách
        List<Transaction> transactions = new ArrayList<>();
        transactions.add(transaction);

        // Tạo đối tượng Payer và thiết lập phương thức thanh toán
        Payer payer = new Payer();
        payer.setPaymentMethod(PayMethodType.PAYPAL.toString());

        // Tạo đối tượng Payment và thiết lập các thuộc tính liên quan
        Payment payment = new Payment();
        payment.setIntent(subscriptionDTO.getIntent());
        payment.setPayer(payer);
        payment.setTransactions(transactions);

        // Tạo đối tượng RedirectUrls và thiết lập các URL chuyển hướng
        RedirectUrls redirectUrls = new RedirectUrls();
        redirectUrls.setCancelUrl(subscriptionDTO.getCancelUrl());
        redirectUrls.setReturnUrl(subscriptionDTO.getSuccessUrl());
        payment.setRedirectUrls(redirectUrls);

        // Tạo một Payment mới trên PayPal

        Payment createdPayment = payment.create(apiContext);
        // Lưu thông tin thanh toán vào cơ sở dữ liệu
        Optional<WorkoutPackage> hotelExisting = workoutPackageRepository.findById(subscriptionDTO.getPackageId());
        MembershipSubscription membershipSubscription = MembershipSubscription.builder()
                .packageId(subscriptionDTO.getPackageId())
                .userId(subscriptionDTO.getUserId())
                .fullName(userExisting.getFullName())
                .buyDate(LocalDateTime.now())
                .startDate(subscriptionDTO.getStartDate())
                .endDate(subscriptionDTO.getEndDate())
                .payMethodType(PayMethodType.valueOf(PayMethodType.PAYPAL.toString()))
                .payStatusType(PayStatusType.valueOf(PayStatusType.PENDING.toString()))
                .packageName(subscriptionDTO.getPackageName())
                .description(subscriptionDTO.getDescription())
                .totalAmount(subscriptionDTO.getTotalAmount())
                .paymentId(createdPayment.getId())
                .build();
        membershipRepository.save(membershipSubscription);
        return createdPayment;
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
}
