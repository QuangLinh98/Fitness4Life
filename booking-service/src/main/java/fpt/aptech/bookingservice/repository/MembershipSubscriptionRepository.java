package fpt.aptech.bookingservice.repository;

import fpt.aptech.bookingservice.models.MembershipSubscription;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MembershipSubscriptionRepository extends JpaRepository<MembershipSubscription, Integer> {
    MembershipSubscription findByPaymentId(String paymentId);
    MembershipSubscription findMemberShipByUserId(long userId);
}
