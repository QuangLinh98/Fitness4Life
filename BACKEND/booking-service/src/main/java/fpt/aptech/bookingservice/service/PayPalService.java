package kj001.booking_service.services;

import com.paypal.api.payments.*;
import com.paypal.base.rest.APIContext;
import com.paypal.base.rest.PayPalRESTException;
import kj001.booking_service.dtos.BookingDTO;
import kj001.booking_service.models.Booking;
import kj001.booking_service.models.PayMethodType;
import kj001.booking_service.models.PayStatusType;
import kj001.booking_service.models.RoomType;
import kj001.booking_service.repository.BookingRepository;
import kj001.booking_service.repository.HotelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PayPalService {
    private final APIContext apiContext;
    private final BookingRepository bookingRepository;
    private final HotelRepository hotelRepository;

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
    public Payment createPayment(BookingDTO bookingDTO) throws PayPalRESTException {
        // Tạo đối tượng Amount và thiết lập tiền tệ và tổng số tiền
        Amount amount = new Amount();
        amount.setCurrency(bookingDTO.getCurrency());
        amount.setTotal(String.format("%.2f", bookingDTO.getTotalAmout()));   //Format cho nó chỉ lấy 2 chữ số phía sau
        // Tạo đối tượng Transaction và thiết lập mô tả và số tiền
        Transaction transaction = new Transaction();
        transaction.setDescription(bookingDTO.getDescription());
        transaction.setAmount(amount);
        // Tạo danh sách các giao dịch và thêm giao dịch vừa tạo vào danh sách
        List<Transaction> transactions = new ArrayList<>();
        transactions.add(transaction);
        // Tạo đối tượng Payer và thiết lập phương thức thanh toán
        Payer payer = new Payer();
        payer.setPaymentMethod(PayMethodType.PAYPAL.toString());
        // Tạo đối tượng Payment và thiết lập các thuộc tính liên quan
        Payment payment = new Payment();
        payment.setIntent(bookingDTO.getIntent());
        payment.setPayer(payer);
        payment.setTransactions(transactions);
        // Tạo đối tượng RedirectUrls và thiết lập các URL chuyển hướng
        RedirectUrls redirectUrls = new RedirectUrls();
        redirectUrls.setCancelUrl(bookingDTO.getCancelUrl());
        redirectUrls.setReturnUrl(bookingDTO.getSuccessUrl());
        payment.setRedirectUrls(redirectUrls);
        // Tạo một Payment mới trên PayPal
        Payment createdPayment = payment.create(apiContext);
        // Lưu thông tin thanh toán vào cơ sở dữ liệu
//        Optional<Hotel> hotelExisting = hotelRepository.findById(bookingDTO.getHotelId());
        Booking bookingHotel = Booking.builder()
                .hotelId(bookingDTO.getHotelId())
                .userId(bookingDTO.getUserId())
                .checkInDate(bookingDTO.getCheckInDate())
                .bookDate(LocalDateTime.now())
                .payMethodType(PayMethodType.valueOf(PayMethodType.PAYPAL.toString()))
                .payStatusType(PayStatusType.valueOf(PayStatusType.PENDING.toString()))
                .roomType(bookingDTO.getRoomType())
                .duration(bookingDTO.getDuration())
                .description(bookingDTO.getDescription())
                .totalAmout(bookingDTO.getTotalAmout())
                .priceType(bookingDTO.getPriceType())
                .paymentId(createdPayment.getId())
                .build();
        bookingRepository.save(bookingHotel);
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
        Booking paymentBooking = bookingRepository.findByPaymentId(paymentId);
        if (paymentBooking != null) {
            paymentBooking.setPayerId(payerId);
            paymentBooking.setPayStatusType(PayStatusType.valueOf(PayStatusType.COMPLETED.toString()));
            bookingRepository.save(paymentBooking);
        }
        return executedPayment;
    }
}
