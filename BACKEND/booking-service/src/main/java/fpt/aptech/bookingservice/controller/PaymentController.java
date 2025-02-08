package fpt.aptech.bookingservice.controller;

import com.paypal.api.payments.Links;
import com.paypal.api.payments.Payment;
import com.paypal.base.rest.APIContext;
import com.paypal.base.rest.PayPalRESTException;
import fpt.aptech.bookingservice.dtos.MembershipSubscriptionDTO;
import fpt.aptech.bookingservice.models.MembershipSubscription;
import fpt.aptech.bookingservice.service.PayPalService;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/paypal/")
@RequiredArgsConstructor
public class PaymentController {
    private final PayPalService payPalService;
    @PostMapping("pay")
    @PreAuthorize("hasAnyAuthority('USER','ADMIN')")
//    public ResponseEntity<?> pay(@RequestBody MembershipSubscriptionDTO subscriptionDTO) {
//        try {
//            Payment payment = payPalService.createPayment(subscriptionDTO);
//            // Duyệt qua các link trong Payment để tìm URL chấp thuận thanh toán (approval_url)
//            for (Links links : payment.getLinks()) {
//                if (links.getRel().equals("approval_url")) {
//                    return ResponseEntity.ok(links.getHref());
//                }
//            }
//        } catch (PayPalRESTException e) {
//            return ResponseEntity.badRequest().body(e.getMessage());
//        }
//        return ResponseEntity.badRequest().body("Error occurred");
//    }

    public ResponseEntity<?> pay(@RequestBody MembershipSubscriptionDTO subscriptionDTO) {
        try {
            System.out.println("✅ Nhận yêu cầu thanh toán từ Flutter: " + subscriptionDTO);

            // Gửi yêu cầu tạo thanh toán đến PayPal
            ResponseEntity<?> response = payPalService.createPayment(subscriptionDTO);

            // Kiểm tra nếu phản hồi từ PayPal có chứa approvalUrl
            if (response.getBody() instanceof Map) {
                Map<?, ?> responseBody = (Map<?, ?>) response.getBody();
                if (responseBody.containsKey("approvalUrl")) {
                    return ResponseEntity.ok(responseBody);
                }
            }

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Không tìm thấy approval URL trong phản hồi của PayPal"));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }


    @PostMapping("success")
    @PreAuthorize("hasAnyAuthority('USER','ADMIN')")
    public ResponseEntity<?> successPay(@RequestParam("paymentId") String paymentId,
                                        @RequestParam("PayerID") String payerID) {
        try {
            Payment payment = payPalService.executePayment(paymentId, payerID);
            return ResponseEntity.ok(payment.toJSON());
        } catch (PayPalRESTException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("getMembershipByPaymentId/{paymentId}")
    public  ResponseEntity<?> getMembershipByPamentId(@PathVariable("paymentId") String paymentId) {
        try {
            MembershipSubscription member = payPalService.getMembershippaymentId(paymentId);
            return ResponseEntity.status(200).body(ResponseEntity.ok(member));
        }catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("getMembershipByUserId/{userId}")
    public  ResponseEntity<?> getMembershipByUserId(@PathVariable("userId") long userId) {
        try {
            MembershipSubscription member = payPalService.getMembershipByUserId(userId);
            return ResponseEntity.status(200).body(ResponseEntity.ok(member));
        }catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
