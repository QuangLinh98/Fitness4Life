package kj001.user_service.controllers;

import jakarta.mail.MessagingException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import kj001.user_service.dtos.*;
import kj001.user_service.helpers.ApiResponse;
import kj001.user_service.models.AuthenticationResponse;
import kj001.user_service.models.User;
import kj001.user_service.repository.UserRepository;
import kj001.user_service.service.AuthenticationService;
import kj001.user_service.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Map;

@RestController
@RequestMapping("/api/users/")
@RequiredArgsConstructor
public class AuthController {
    private final UserService userService;
    private final UserRepository userRepository;
    private final AuthenticationService authenticationService;


    @PostMapping("register")
    public ResponseEntity<?> createOneUser(@Valid @RequestBody CreateUserDTO createUserDTO, BindingResult bindingResult) {
        // kiểm tra lỗi validation
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            UserResponseDTO createdUser = userService.createUser(createUserDTO);
            return ResponseEntity.status(201).body(ApiResponse.created(createdUser, "User register successfully."));
        } catch (RuntimeException ex) {
            if (ex.getMessage().contains("UserActiveExists")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("User active exists"));
            } else if (ex.getMessage().contains("EmailAlready3TimeOfDay")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Email Already used 3 Time Of Day"));
            } else if (ex.getMessage().contains("ConfirmEqualNewPassword")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Confirm Password does not match new pass"));
            } else {
                return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
            }
        } catch (MessagingException | IOException e) {
            return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + e.getMessage()));
        }
    }

    @GetMapping("verify-account/{code}")
    public ResponseEntity<?> verifyAccount(@PathVariable String code) {
        try {
            boolean response  = authenticationService.verifyAndActivateAccount(code);
            return ResponseEntity.ok(response );
        } catch (RuntimeException ex) {
            if (ex.getMessage().contains("OTPHasExpired")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("OTP has expired"));
            } else if (ex.getMessage().contains("OTPVERIFIED")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Account has verified"));
            } else {
                return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
            }
        }
    }

    @GetMapping("verify-account2/{code}")
    public ResponseEntity<?> verifyAccount2(@PathVariable String code) {
        try {
            Map<String, Object> response = authenticationService.verifyAccount2(code);
            return ResponseEntity.ok(response);
        } catch (RuntimeException ex) {
            if (ex.getMessage().contains("OTPHasExpired")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("OTP has expired"));
            } else if (ex.getMessage().contains("OTPVERIFIED")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Account has verified"));
            } else {
                return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
            }
        }
    }

    @PostMapping("login")
    public ResponseEntity<AuthenticationResponse> login(@RequestBody User request)
    {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }

    @PostMapping("change-pass")
    public ResponseEntity<?> changePass(@Valid
                                        @RequestBody ChangePasswordRequestDTO changePasswordRequestDTO,
                                        BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            if (userService.changePassword(changePasswordRequestDTO)) {
                return ResponseEntity.ok(ApiResponse.success(true, "Password changed successfully"));
            } else {
                return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
            }
        } catch (Exception ex) {
            if (ex.getMessage().contains("UserNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("User with the given email does not exist"));
            } else if (ex.getMessage().contains("OldPasswordDoesNotMatch")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Old password does not match"));
            } else if (ex.getMessage().contains("NewPasswordMustBeDifferenceFormOldPassword")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("New password must be difference old pass"));
            } else if (ex.getMessage().contains("ConfirmPasswordMustBeEqualNewPassword")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("Confirm password does not match new pass"));
            } else {
                return ResponseEntity.status(500).body(ApiResponse.errorServer("Unexpected error: " + ex.getMessage()));
            }
        }
    }

    @PostMapping("send-otp")
    public ResponseEntity<?> sendOtp(@Valid @RequestBody
                                     SendOtpRequestDTO sendOtpRequestDTO, BindingResult bindingResult) throws MessagingException, UnsupportedEncodingException {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            userService.sendOTP(sendOtpRequestDTO);
            return ResponseEntity.ok(ApiResponse.success(true, "OTP sent successfully"));
        } catch (RuntimeException ex) {
            if (ex.getMessage().contains("UserNotFound")) {
                return ResponseEntity.status(404).body(ApiResponse.notfound("User with the given email does not exist"));
            } else if (ex.getMessage().contains("LimitOTPDay")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("OTP request send limit Today"));
            }
        } catch (MessagingException | UnsupportedEncodingException e) {
            // Handle messaging exceptions
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiResponse.errorServer("Unexpected error: " + e.getMessage()));
        }
        return ResponseEntity.status(400).body(ApiResponse.badRequest("Failed to send OTP"));
    }

    @PostMapping("reset-password")
    public ResponseEntity<?> resetPassword(@Valid @RequestBody
                                           VerifyOTPRequestDTO resetPasswordRequestDTO, BindingResult bindingResult) throws MessagingException, UnsupportedEncodingException {
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(ApiResponse.badRequest(bindingResult));
        }
        try {
            userService.resetPassword(resetPasswordRequestDTO);
            return ResponseEntity.ok(ApiResponse.success(true, "Reset Password successfully"));
        } catch (RuntimeException ex) {
            if (ex.getMessage().contains("OTPHasExpired")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("OTP has expired"));
            } else if (ex.getMessage().contains("OTPIsUsed")) {
                return ResponseEntity.status(400).body(ApiResponse.badRequest("OTP has already been used"));
            }
        } catch (MessagingException e) {
            // Handle messaging exceptions
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ApiResponse.errorServer("Unexpected error: " + e.getMessage()));
        }
        return ResponseEntity.status(400).body(ApiResponse.badRequest("Failed to reset"));
    }

    @PostMapping("refresh_token")
    public ResponseEntity refreshToken(HttpServletRequest request, HttpServletResponse response) {
        return authenticationService.refreshToken(request, response);
    }
}
