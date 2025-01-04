package fpt.aptech.api_gateway.jwt_util;


import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;



@Component
public class JwtUtil {

    @Value("${spring.application.security.jwt.secret-key}")
    private String secretKey;

    @Value("${spring.application.security.jwt.access-token-expiration}")
    private long accessTokenExpire;   // Thời gian hết hạn của Access Token

    @Value("${spring.application.security.jwt.refresh-token-expiration}")
    private long refreshTokenExpire;   // Thời gian hết hạn của Refresh Token

    // Phương thức xác thực token có hơp lệ hay không
    public boolean validateToken(String token) {
        try {
            Jwts.parser() // Sử dụng parserBuilder thay vì parser
                    .setSigningKey(getSigningKey()) // Đặt signing key
                    .build() // Xây dựng parser
                    .parseClaimsJws(token); // Phân tích token
            System.out.println("token validated");
            return true;  // Token hợp lệ
        } catch (Exception e) {
            System.out.println("token inValid");
            return false; // Token không hợp lệ
        }
    }

    // Trích xuất thông tin từ JWT , claimKey: Tên của thông tin cần trích xuất
    //Logic : Giải mã token để lấy thông tin
    public String extractClaim(String token, String claimKey) {
        try {
            Claims claims = Jwts.parser()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return claims.get(claimKey, String.class); // Trích xuất "sub"
        } catch (Exception e) {
            System.out.println("Failed to extract userId: " + e.getMessage());
            return null;
        }
    }

    // Trích xuất thông tin User từ token (cụ thể là lấy userId)
    public String extractUserId(String token) {
        return extractClaim(token, "sub"); // "sub" là subject chứa userId
    }

    // Trích xuất role từ token
    public String extractUserRole(String token) {
        String role = extractClaim(token, "role"); // Lấy giá trị role từ token
        System.out.println("Extracted Role: " + role); // In giá trị role
        return extractClaim(token, "role");
    }

    // Lấy secret key để ký/giải mã JWT
    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64URL.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
