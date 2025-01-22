package kj001.user_service.repository;

import kj001.user_service.models.OTP;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpRepository extends JpaRepository<OTP , Long> {
   Optional<OTP> findByOtpCode(String otpCode);

   //Câu truy vấn sử dụng trong database MySql
//   @Query(value = "SELECT * FROM OTP o WHERE o.email = :email ORDER BY o.last_Send DESC LIMIT 1" , nativeQuery = true)
//   Optional<OTP> findLastOtpByEmail(@Param("email") String email);

   //Câu truy vấn sử dụng trong database SqlServer
   @Query(value = "SELECT * FROM OTP o WHERE o.email = :email ORDER BY o.last_Send DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY", nativeQuery = true)
   Optional<OTP> findLastOtpByEmail(@Param("email") String email);

}
