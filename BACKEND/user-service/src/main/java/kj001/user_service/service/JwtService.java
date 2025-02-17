package kj001.user_service.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import kj001.user_service.models.User;
import kj001.user_service.repository.TokenRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Date;
import java.util.function.Function;
import java.util.logging.Logger;

@Service
public class JwtService {
    private final TokenRepository tokenRepository;

    public JwtService(TokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    @Value("${spring.application.security.jwt.secret-key}")
    private String secretKey;  //Khóa bí mật dùng để ký JWT

    @Value("${spring.application.security.jwt.access-token-expiration}")
    private long accessTokenExpire;   // Thời gian hết hạn của Access Token

    @Value("${spring.application.security.jwt.refresh-token-expiration}")
    private long refreshTokenExpire;   // Thời gian hết hạn của Refresh Token

    // Phương thức tạo Refresh Token cho người dùng
    public String generateRefreshToken(User user) {
        return generateToken(user, refreshTokenExpire); // Tạo Refresh Token với thời gian hết hạn
    }

    // Phương thức tạo Access Token cho người dùng
    public String generateAccessToken(User user) {
        return generateToken(user, accessTokenExpire); // Tạo Access Token với thời gian hết hạn
    }


    // Phương thức tạo token với thời gian hết hạn được truyền vào
    private String generateToken(User user, long expireTime) {
        String token = Jwts
                .builder() // Bắt đầu xây dựng JWT
                .subject(user.getUsername()) // Đặt "subject" là username của người dùng
                .claim("id", user.getId())
                .claim("role", user.getRole()) // Thêm thông tin role của người dùng vào claims
                .claim("fullName", user.getFullName()) // Thêm thông tin fullName
                .issuedAt(new Date(System.currentTimeMillis())) // Thiết lập ngày phát hành token
                .expiration(new Date(System.currentTimeMillis() + expireTime)) // Thiết lập ngày hết hạn token
                .signWith(getSigningKey(), SignatureAlgorithm.HS384) // Ký token bằng khóa bí mật
                .compact(); // Hoàn tất việc xây dựng và trả về token
        System.out.println("Secret Key (Base64URL): " + secretKey);
        System.out.println("Decoded Key: " + Arrays.toString(getSigningKey().getEncoded()));
        System.out.println("Generated Token: " + token);

        return token; // Trả về JWT đã được tạo
    }

    // Phương thức để trích xuất username từ JWT token
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject); // Trích xuất "subject" từ claims của token
    }

    // Phương thức trích xuất một claim bất kỳ từ token
    public <T> T extractClaim(String token, Function<Claims, T> resolver) {
        Claims claims = extractAllClaims(token); // Trích xuất toàn bộ claims từ token
        return resolver.apply(claims); // Áp dụng hàm resolver để lấy claim mong muốn
    }

    // Phương thức trích xuất toàn bộ claims từ token
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // Phương thức lấy khóa bí mật để ký JWT
    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64URL.decode(secretKey); // Giải mã khóa bí mật từ chuỗi base64url
        return Keys.hmacShaKeyFor(keyBytes); // Trả về khóa bí mật dưới dạng SecretKey cho HMAC
    }

    // Phương thức để kiểm tra xem token có hợp lệ hay không
    public boolean isValid(String token, UserDetails user) {
        System.out.println("Có lọt vào đây không ");
        Logger logger = Logger.getLogger(this.getClass().getName()); // Tạo logger

        String username = extractUsername(token); // Lấy username từ token
        logger.info("Extracted username from token: " + username);

        // Kiểm tra trong cơ sở dữ liệu xem token này đã bị đăng xuất hay chưa
        boolean validToken = tokenRepository
                .findByAccessToken(token)
                .map(t -> !t.isLoggedOut()) // Token vẫn hợp lệ nếu chưa bị đăng xuất
                .orElse(false);

        // Kiểm tra điều kiện Token hợp lệ nếu username khớp, chưa hết hạn, và chưa bị đăng xuất
        boolean isValid = username.equals(user.getUsername()) && !isTokenExpired(token) && validToken;

        // Ghi log trạng thái token
        if (isValid) {
            logger.info("Token is valid for user: " + user.getUsername());
        } else {
            logger.warning("Token is invalid. Details:");
            if (!username.equals(user.getUsername())) {
                logger.warning(" - Username mismatch. Expected: " + user.getUsername() + ", Found: " + username);
            }
            if (isTokenExpired(token)) {
                logger.warning(" - Token is expired.");
            }
            if (!validToken) {
                logger.warning(" - Token has been logged out or not found in the repository.");
            }
        }

        return isValid;
    }

    // Phương thức kiểm tra xem token có hết hạn hay chưa
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date()); // Kiểm tra nếu ngày hết hạn trước ngày hiện tại
    }

    // Phương thức trích xuất ngày hết hạn từ token
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration); // Lấy thông tin expiration từ claims của token
    }

    // Phương thức kiểm tra tính hợp lệ của Refresh Token
    public boolean isValidRefreshToken(String token, User user) {
        String username = extractUsername(token); // Lấy username từ token

        // Kiểm tra tính hợp lệ của Refresh Token trong cơ sở dữ liệu
        boolean validRefreshToken = tokenRepository
                .findByRefreshToken(token)
                .map(t -> !t.isLoggedOut())
                .orElse(false);

        // Refresh Token hợp lệ nếu username khớp, chưa hết hạn, và token chưa bị đăng xuất
        return (username.equals(user.getUsername())) && !isTokenExpired(token) && validRefreshToken;
    }
}
