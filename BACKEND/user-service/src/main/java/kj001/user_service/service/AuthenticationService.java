package kj001.user_service.service;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import kj001.user_service.models.AuthenticationResponse;
import kj001.user_service.models.Token;
import kj001.user_service.models.User;
import kj001.user_service.repository.TokenRepository;
import kj001.user_service.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

// Đánh dấu class là một Spring service
@Service

public class AuthenticationService {

    // Khai báo các dependency cần thiết
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PasswordEncoder passwordEncoder; // Để mã hóa mật khẩu người dùng
    @Autowired
    private JwtService jwtService; // Để tạo và xác thực JWT tokens
    @Autowired
    private TokenRepository tokenRepository; // Repository để quản lý token
    @Autowired
    private AuthenticationManager authenticationManager; // Spring Security để xác thực người dùng

    // Constructor injection cho các dependency
    public AuthenticationService(UserRepository userRepository,
                                 PasswordEncoder passwordEncoder,
                                 JwtService jwtService,
                                 TokenRepository tokenRepository,
                                 AuthenticationManager authenticationManager
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.tokenRepository = tokenRepository;
        this.authenticationManager = authenticationManager;
    }

    // Phương thức kích hoạt tài khoản sau khi user đăng ký thành công
    @Transactional
    public boolean verifyAndActivateAccount( String otpCode) {

        // Kiểm tra xem người dùng đã tồn tại hay chưa, nếu đã tồn tại thì trả về phản hồi lỗi
        User user = userRepository.findByOtpCode(otpCode)
                .orElseThrow(() -> new RuntimeException("Invalid OTP"));

        // Kiểm tra OTP có khớp không và còn hiệu lực không
        if (!otpCode.equals(user.getOtpCode()) || user.getExpiryTime().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Invalid OTP provided.");
        }

        // Nếu tài khoản đã kích hoạt
        if (user.isActive()) {
            throw new RuntimeException("OTP has expired.");
        }

        // Kích hoạt tài khoản
        user.setActive(true);
        userRepository.save(user);

        // Xóa các bản ghi không kích hoạt khác có cùng email
        userRepository.deleteInactiveUsersByEmail(user.getEmail(), user.getId());

        return true;
    }

    // Phương thức để xác thực người dùng (Login)
    public AuthenticationResponse authenticate(User request) {
        // Sử dụng AuthenticationManager để xác thực người dùng dựa trên username và password
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        // Tìm người dùng theo email từ cơ sở dữ liệu, nếu không tìm thấy thì throw exception
        User user = userRepository.findByEmail(request.getUsername()).orElseThrow(() -> new RuntimeException("UserNotFound"));

        // Tạo Access Token và Refresh Token mới cho người dùng
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        // Hủy tất cả các token cũ của người dùng (nếu có)
        revokeAllTokenByUser(user);

        // Lưu lại token mới cho người dùng
        saveUserToken(accessToken, refreshToken, user);

        // Trả về phản hồi xác thực thành công với các token mới
        return new AuthenticationResponse(accessToken, refreshToken, "User login was successful");
    }

    // Phương thức để hủy tất cả các token hợp lệ của người dùng
    private void revokeAllTokenByUser(User user) {
        // Lấy tất cả các token hợp lệ của người dùng
        List<Token> validTokens = tokenRepository.findAllAccessTokensByUser(user.getId());
        if (validTokens.isEmpty()) {
            return; // Nếu không có token hợp lệ thì kết thúc
        }

        // Đánh dấu tất cả các token là đã đăng xuất
        validTokens.forEach(t -> {
            t.setLoggedOut(true);
        });

        // Lưu lại các token đã cập nhật
        tokenRepository.saveAll(validTokens);
    }

    // Phương thức để lưu thông tin token của người dùng
    private void saveUserToken(String accessToken, String refreshToken, User user) {
        Token token = new Token();
        token.setAccessToken(accessToken);
        token.setRefreshToken(refreshToken);
        token.setLoggedOut(false); // Đặt trạng thái là chưa đăng xuất
        token.setUser(user); // Gán người dùng cho token
        tokenRepository.save(token);
    }

    // Phương thức để refresh token của người dùng
    public ResponseEntity refreshToken(
            HttpServletRequest request,
            HttpServletResponse response) {
        // Lấy token từ header Authorization
        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        // Kiểm tra nếu header không hợp lệ
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return new ResponseEntity(HttpStatus.UNAUTHORIZED); // Trả về mã lỗi không được phép
        }

        // Tách token ra từ chuỗi Bearer
        String token = authHeader.substring(7);

        // Lấy email từ token
        String email = jwtService.extractUsername(token);

        // Tìm người dùng theo email
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("No user found"));

        // Kiểm tra tính hợp lệ của Refresh Token
        if (jwtService.isValidRefreshToken(token, user)) {
            // Nếu hợp lệ thì tạo Access Token mới và Refresh Token mới
            String accessToken = jwtService.generateAccessToken(user);
            String refreshToken = jwtService.generateRefreshToken(user);

            // Hủy tất cả các token cũ và lưu lại token mới
            revokeAllTokenByUser(user);
            saveUserToken(accessToken, refreshToken, user);

            // Trả về phản hồi với các token mới
            return new ResponseEntity(new AuthenticationResponse(accessToken, refreshToken, "New token generated"), HttpStatus.OK);
        }

        // Nếu token không hợp lệ thì trả về mã lỗi không được phép
        return new ResponseEntity(HttpStatus.UNAUTHORIZED);
    }
}
