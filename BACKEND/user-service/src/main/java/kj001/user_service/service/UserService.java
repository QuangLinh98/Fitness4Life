package kj001.user_service.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.mail.MessagingException;
import jakarta.transaction.Transactional;
import kj001.user_service.dtos.*;
import kj001.user_service.helpers.ApiResponse;
import kj001.user_service.helpers.FileUpload;
import kj001.user_service.models.*;
import kj001.user_service.repository.OtpRepository;
import kj001.user_service.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor

public class UserService {
    private final UserRepository userRepository;
    private final OtpRepository otpRepository;
    private final MailResetPass mailResetPass;
    private final ObjectMapper objectMapper;
    private PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final FileUpload fileUpload;
    private String subFolder = "avatarImage";
    String uploadFolder = "uploads";
    private String rootUrl = "http://localhost:8080/";
    private String urlImage = rootUrl + uploadFolder + File.separator + subFolder;
    private static final int OTP_EXPIRATION_MINUTES = 5;   //Đặt thời gian hết hạn cho mã OTP

    //Phương thức Show Data
    public List<UserResponseDTO> getAllUser() {
        List<User> users = userRepository.findAll();
        return users.stream().map(user -> {
            UserResponseDTO dto = objectMapper.convertValue(user, UserResponseDTO.class);

            //set dto
            if (user.getProfile() != null) {
                ProfileDTO profileDTO = new ProfileDTO();
                profileDTO.setHobbies(user.getProfile().getHobbies());
                profileDTO.setAddress(user.getProfile().getAddress());
                profileDTO.setAvatar(user.getProfile().getAvatar());
                profileDTO.setAge(user.getProfile().getAge());
                profileDTO.setHeightValue(user.getProfile().getHeightValue());
                profileDTO.setMaritalStatus(user.getProfile().getMaritalStatus());
                profileDTO.setDescription(user.getProfile().getDescription());
                dto.setProfileDTO(profileDTO); // Set the profileDTO in the UserResponseDTO
            }
            return dto;
        }).collect(Collectors.toList());
    }

    @Transactional // Đảm bảo cập nhật được thực thi trong một transaction
    public void assignPackageToUser(Long userId, Integer packageId) {
        userRepository.updateUserPackageId(userId, packageId);
    }

    //Hàm xử lý chỉ để giao tiếp feign client
    public UserDTO getUserById(Long id) {
        Optional<User> existingUser = userRepository.findById(id);

        if (existingUser.isEmpty()) {
            return null;
        }

        User user = existingUser.get();

        // Get profile data
        Profile profile = user.getProfile();
        ProfileUserDTO profileUserDTO = (profile != null) ?
                new ProfileUserDTO(profile.getAge(), profile.getHeightValue()) : null;

        // Get face data
        FaceDataDTO faceDataDTO = null;
        // Use the reference from the user object instead of a separate repository call
        FaceData faceData = user.getFaceData();

        if (faceData != null) {
            faceDataDTO = FaceDataDTO.builder()
                    .userId(user.getId())
                    .faceEncoding(faceData.getFaceEncoding())
                    .originalImagePath(faceData.getOriginalImagePath())
                    .hasFaceData(faceData.getFaceEncoding() != null && !faceData.getFaceEncoding().trim().isEmpty())
                    .build();
        }

        // Build the complete user DTO with profile and face data
        UserDTO userDTO = UserDTO.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .gender(user.getGender())
                .profileUserDTO(profileUserDTO)
                .faceDataDTO(faceDataDTO)  // Thêm face data vào response
                .build();

        return userDTO;
    }

    //Hàm xử lý để lấy thông tin để hiên thị profile
    public UserResponseDTO getUserByIdToShowProfile(long userId) {
        Optional<User> existingUser = userRepository.findById(userId);

        if (existingUser.isEmpty()) {
            throw new RuntimeException("User not found with ID: " + userId);
        }

        User user = existingUser.get();
        Profile profile = user.getProfile();
        FaceData faceData = user.getFaceData();

        // Nếu Profile chưa tồn tại, tạo một ProfileDTO rỗng
        ProfileDTO profileDTO = new ProfileDTO();

        if (profile != null) {
            profileDTO.setHobbies(profile.getHobbies());
            profileDTO.setAddress(profile.getAddress());
            profileDTO.setAge(profile.getAge());
            profileDTO.setHeightValue(profile.getHeightValue());
            profileDTO.setAvatar(profile.getAvatar());
            profileDTO.setDescription(profile.getDescription());
            profileDTO.setMaritalStatus(profile.getMaritalStatus());
        }

        // Xử lý FaceData
        FaceDataDTO faceDataDTO = null;
        if (faceData != null) {
            faceDataDTO = FaceDataDTO.builder()
                    .userId(user.getId())
                    .faceEncoding(faceData.getFaceEncoding())
                    .originalImagePath(faceData.getOriginalImagePath())
                    .hasFaceData(faceData.getFaceEncoding() != null && !faceData.getFaceEncoding().trim().isEmpty())
                    .build();
        }

        return UserResponseDTO.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .workoutPackageId(user.getWorkoutPackageId())
                .email(user.getEmail())
                .isActive(user.isActive())
                .phone(user.getPhone())
                .role(user.getRole())
                .gender(user.getGender())
                .profileDTO(profileDTO)
                .faceDataDTO(faceDataDTO)
                .build();
    }

    public User findByEmail(String email) {
        // Validate the email input
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email must not be null or empty.");
        }
        try {
            // Attempt to find the user by email
            Optional<User> userOptional = userRepository.findByEmail(email);

            // Handle case where user is not found
            return userOptional.orElseThrow(() ->
                    new UsernameNotFoundException("User with email '" + email + "' not found.")
            );

        } catch (IllegalArgumentException ex) {
            // Rethrow validation-related exceptions
            throw ex;

        } catch (Exception ex) {
            // Catch and rethrow unexpected exceptions
            throw new RuntimeException("An unexpected error occurred while fetching the user: " + ex.getMessage(), ex);
        }
    }

    //Phương thức Register User
    @Transactional
    public UserResponseDTO createUser(CreateUserDTO createUserDTO) throws MessagingException, IOException {
        // Chuẩn hóa email từ DTO
        String normalizedEmail = normalizeEmail(createUserDTO.getEmail());
        createUserDTO.setEmail(normalizedEmail);

        //Kiểm tra nếu có bất kỳ user nào với email đang acive
        List<User> existingActiveUsers = userRepository.findByEmailAndIsActiveTrue(createUserDTO.getEmail());
        if (!existingActiveUsers.isEmpty()) {
            throw new RuntimeException("User active exists");
        }
        //Lấy thời gian hiện tại
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startDay = now.toLocalDate().atStartOfDay();
        LocalDateTime endDay = now.toLocalDate().atTime(23, 59, 59);

        //Tìm người dùng có cùng email và đã đăng ký trong ngày
        List<User> existingUserToday = userRepository
                .findByEmailAndRegistrationDateBetween(createUserDTO.getEmail(), startDay, endDay);
        //Kiểm tra với email đó trong ngày đã đăng ký mấy lần
        if (existingUserToday.size() >= 3) {
            throw new RuntimeException("Email already 3 time of day");
        }
        //Xóa những bản ghi cũ cho email đã đăng ký ngày trước hôm nay mà chưa active
        userRepository.deleteByEmailAndRegistrationDateBeforeAndIsActiveFalse(createUserDTO.getEmail(), startDay);

        //Kiểm tra newPass và ConfirmPass có trùng nhau hay không
        if (!createUserDTO.getPassword().equals(createUserDTO.getConfirmPassword())) {
            throw new RuntimeException("Confirm equal new password");
        }
        User user = objectMapper.convertValue(createUserDTO, User.class);  //Chuyển đổi đối tượng createUserDTO<dữ liệu người dùng nhập vào> sang User để lưu vào dữ liệu . Điều này có nghĩa là dữ liệu createUserDTO sẽ được sao chép vào User và lưu vào database vì DTO sẽ không trực tiếp lưu vào DB
        user.setPassword(passwordEncoder.encode(createUserDTO.getPassword()));  //Mã hóa password trước khi lưu vào DB

        String otpCode = generateOtp();   //Tạo mã OTP
        user.setOtpCode(otpCode);
        user.setCreateAt(LocalDateTime.now());    //Thiết lập time tạo user
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES);   //Set Thời gian hết hạn
        user.setExpiryTime(expiryTime);
        userRepository.save(user);
        UserResponseDTO userResponseDTO = objectMapper.convertValue(user, UserResponseDTO.class);

        //Logic gửi mail khi user đăng ký tài khoản và xác thực bằng OTP bằng template
        String templatePath = "templates/otp_email_template.html";
        String emailTemplate = new String(Files.readAllBytes(Paths.get(templatePath)));
        String emailContent = emailTemplate.replace("[EMAIL]", createUserDTO.getEmail())
                .replace("[OTP_CODE]", otpCode);
        MailEntity mailEntity = new MailEntity();
        mailEntity.setEmail(createUserDTO.getEmail());
        mailEntity.setSubject("Verify Account");
        mailEntity.setContent(emailContent);
        mailResetPass.sendMailOTP(mailEntity);
        return userResponseDTO;
    }

    //Hàm chuẩn hóa email tránh lỗ hổng 1 email có thể đăng ký nhiều account
    private String normalizeEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email; // Nếu email không hợp lệ, trả về như ban đầu
        }
        // Tách email thành phần local và domain
        String[] parts = email.split("@");
        String localPart = parts[0].split("\\+")[0].toLowerCase(); // Lấy phần trước dấu '+' và chuyển về chữ thường
        String domainPart = parts[1].toLowerCase(); // Chuyển domain về chữ thường
        return localPart + "@" + domainPart; // Gộp lại email đã chuẩn hóa
    }


    //Phương thức Update User
    public Optional<UserResponseDTO> updateUser(Long userId, UserAndProfileUpdateDTO userAndProfileUpdateDTO) throws IOException {
        System.out.println("Request flutter gửi xuống yêu cầu update profile :  " + userAndProfileUpdateDTO);
        Optional<User> existingUser = userRepository.findById(userId);
        if (existingUser.isPresent()) {
            User user = existingUser.get();

            // Giữ nguyên role nếu không được gửi từ DTO, mặc định là USER nếu role chưa có
            if (userAndProfileUpdateDTO.getRole() != null) {
                user.setRole(userAndProfileUpdateDTO.getRole());
            } else if (user.getRole() == null) {
                user.setRole(Roles.USER); // 🔥 Nếu role bị null, đặt mặc định USER
            }

            Roles currentRole = user.getRole();

            //Sử dụng objectMapper để update dữ liệu dựa trên UserAndProfileUpdateDTO
            objectMapper.updateValue(user, userAndProfileUpdateDTO);
            user.setRole(currentRole);

            //Xử lý thông tin profile
            Profile profile = user.getProfile();
            if (profile == null) {
                profile = new Profile();   //Tạo 1 đối tượng rỗng
                profile.setUser(user);
            }
            //Xử lý Upload avatar nếu có
            MultipartFile avatarFile = userAndProfileUpdateDTO.getFile();
            if (avatarFile != null && !avatarFile.isEmpty()) {
                String avatarUrl = profile.getAvatar();
                if (avatarUrl != null) {
                    fileUpload.deleteImage(avatarUrl.substring(rootUrl.length()));
                }

                //Lưu file và lấy file
                String imageName = fileUpload.storeImage(subFolder, avatarFile);

                //Tạo đường dẫn đầy đủ cho file
                String exacImagePath = urlImage + File.separator + imageName;

                //Cập nhật URL của hình đại diện trong profile
                userAndProfileUpdateDTO.setAvatar(exacImagePath.replace("\\", "/"));
            } else {
                userAndProfileUpdateDTO.setAvatar(profile.getAvatar());
            }
            //Cập nhật các thông tin profile từ DTO
            objectMapper.updateValue(profile, userAndProfileUpdateDTO);
            user.setProfile(profile);

            if (user.getRole() == null) {
                user.setRole(Roles.USER); // Đảm bảo role không bị null trước khi lưu
            }

            //Lưu thông tin User và Profile
            userRepository.save(user);
            return Optional.of(convertToUserResponseDTO(user));
        }
        return Optional.empty();
    }

    //Phương thức delete User
    public UserResponseDTO deleteUser(long userId) {
        Optional<User> existingUser = userRepository.findById(userId);
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            userRepository.deleteById(userId);
            return objectMapper.convertValue(user, UserResponseDTO.class);
        }
        return null;
    }

    //Phương thức chuyển đổi đối tượng User sang UserResponseDTO
    private UserResponseDTO convertToUserResponseDTO(User user) {
        UserResponseDTO userResponseDTO = objectMapper.convertValue(user, UserResponseDTO.class);
        //Kiểm tra user có profile hay không
        if (user.getProfile() != null) {
            //Chuyển đổi đối tương profile sang profileDTO
            ProfileDTO profileDTO = objectMapper.convertValue(user.getProfile(), ProfileDTO.class);
            //Thiết lập avatar cho profileDTO
            profileDTO.setAvatar(user.getProfile().getAvatar());
            //Gán profileDTO vào userResponseDTO thông qua phương thức Set
            userResponseDTO.setProfileDTO(profileDTO);
        }
        return userResponseDTO;
    }

    //Phương thức Change Password
    public boolean changePassword(ChangePasswordRequestDTO changePasswordRequestDTO) {
        //Lấy email từ SecurityContext (đã xác thực)
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        System.out.println("Test Email : " + email);

        // Tìm người dùng theo email
        User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("UserNotFound"));

        //Kiểm tra xem oldPassword có khớp hay không
        if (!passwordEncoder.matches(changePasswordRequestDTO.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("OldPasswordDoesNotMatch");
        }
        //KIểm tra xem newPassword có trùng với oldPassword hay không
        if (passwordEncoder.matches(changePasswordRequestDTO.getNewPassword(), user.getPassword())) {
            throw new RuntimeException("NewPasswordMustBeDifferenceFormOldPassword");
        }
        //KIểm tra xem newPassword có trùng với confirmPassword hay không
        if (!changePasswordRequestDTO.getNewPassword().equals(changePasswordRequestDTO.getConfirmPassword())) {
            throw new RuntimeException("ConfirmPasswordMustBeEqualNewPassword");
        }

        //Mã hóa newPassword và update
        user.setPassword(passwordEncoder.encode(changePasswordRequestDTO.getNewPassword()));
        userRepository.save(user);
        return true;
    }

    //Phương thức gửi OTP
    public void sendOTP(SendOtpRequestDTO sendOtpRequestDTO) throws MessagingException, UnsupportedEncodingException {
        userRepository.findByEmail(sendOtpRequestDTO.getEmail()).orElseThrow(() -> new RuntimeException("UserNotFound"));

        String otpCode = generateOtp();
        //Đặt thời gian hết hạn của OTP là 5 phút
        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES);

        //Tìm OTP mới nhất được gửi cho mail này
        Optional<OTP> existingOTP = otpRepository.findLastOtpByEmail(sendOtpRequestDTO.getEmail());
        if (existingOTP.isPresent()) {
            OTP otpExisting = existingOTP.get();
            if (otpExisting.getLastSend().toLocalDate().isEqual(LocalDateTime.now().toLocalDate())) {
                if (otpExisting.getSendAttemps() >= 3) {
                    throw new RuntimeException("LimitOTPDay");
                }
            }
        }
        //Lưu mã OTP vào trong CSDL table OTP
        OTP otp = new OTP();
        otp.setOtpCode(otpCode);
        otp.setEmail(sendOtpRequestDTO.getEmail());
        otp.setSubject("Reset Password OTP");
        otp.setContent("Your OTP code is " + otpCode + ".It expries in 5 minutes");
        otp.setUsed(false);
        otp.setSendAttemps(existingOTP.map(otp1 -> otp1.getSendAttemps() + 1).orElse(1));    //Số lần gửi OTP sẽ được tăng lên
        otp.setExpiryTime(expiryTime);
        otp.setLastSend(LocalDateTime.now());
        otpRepository.save(otp);

        //Login send mail mã OTP
        MailEntity mailEntity = new MailEntity();
        mailEntity.setEmail(sendOtpRequestDTO.getEmail());
        mailEntity.setSubject(otp.getSubject());
        mailEntity.setContent(otp.getContent());
        mailResetPass.sendMailOTP(mailEntity);
    }

    //phương thức tạo mã OTP ngẫu nhiên
    private String generateOtp() {
        Random random = new Random();
        //Tạo ngẫu nhiên 6 chữ số
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }

    //Logic ResetPassword
    public boolean resetPassword(VerifyOTPRequestDTO resetPasswordRequestDTO) throws MessagingException, UnsupportedEncodingException {
        // Tìm mã OTP và email liên kết với mã đó
        OTP otp = otpRepository.findByOtpCode(resetPasswordRequestDTO.getOtpCode())
                .orElseThrow(() -> new RuntimeException("Invalid OTP"));

        // Kiểm tra OTP đã hết hạn chưa
        if (otp.getExpiryTime().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("OTP has expired");
        }

        // Kiểm tra nếu OTP đã được sử dụng
        if (otp.isUsed()) {
            throw new RuntimeException("OTP has already been used");
        }

        // Lấy email từ mã OTP
        String email = otp.getEmail();

        // Tạo mật khẩu mới
        String newPassword = generateRandomPassword();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        // Đánh dấu OTP là đã sử dụng
        otp.setUsed(true);
        otpRepository.save(otp);

        // Gửi mật khẩu mới qua email
        MailEntity mailEntity = new MailEntity();
        mailEntity.setEmail(email);
        mailEntity.setSubject("Your new password");
        mailEntity.setContent("Your new password is: " + newPassword);
        mailResetPass.sendMailOTP(mailEntity);

        return true;
    }

    //Tạo 1 hàm password random
    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }
}
