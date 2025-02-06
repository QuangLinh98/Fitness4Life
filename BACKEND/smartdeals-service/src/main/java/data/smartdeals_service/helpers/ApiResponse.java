package data.smartdeals_service.helpers;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;

import java.util.List;
import java.util.stream.Collectors;

@Data
@AllArgsConstructor
public class ApiResponse<T> {
    private T data;
    private String message;
    private int status;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<String> errors;

    public ApiResponse(T data, String message, int status) {
        this.data = data;
        this.message = message;
        this.status = status;
    }

    // Success
    public static <T> ApiResponse<T> success(T data, String message) {
        return new ApiResponse<>(data, message, 200);
    }

    // Created
    public static <T> ApiResponse<T> created(T data, String message) {
        return new ApiResponse<>(data, message, 201);
    }

    // Not Found
    public static <T> ApiResponse<T> notfound(String message) {
        return new ApiResponse<>(null, message, 404, null);
    }

    public static <T> ApiResponse<T> notfound(T data, String message) {
        return new ApiResponse<>(data, message, 404, null);
    }

    // Bad Request with message
    public static <T> ApiResponse<T> badRequest(String message) {
        return new ApiResponse<>(null, message, 400, null);
    }

    // Bad Request with validation errors
    public static <T> ApiResponse<Object> badRequest(BindingResult bindingResult) {
        List<String> errorsBadRequest = bindingResult.getAllErrors().stream()
                .map(ObjectError::getDefaultMessage)
                .collect(Collectors.toList());
        return new ApiResponse<>(null, "Validation errors", 400, errorsBadRequest);
    }

    // Server Error
    public static <T> ApiResponse<T> errorServer(String message) {
        return new ApiResponse<>(null, message, 500, null);
    }

    // Custom Error Responses (Avoid duplicate HTTP status codes)
    // Conflict
    public static <T> ApiResponse<T> conflict(String message) {
        return new ApiResponse<>(null, message, 409, null);
    }

    // Unprocessable Entity
    public static <T> ApiResponse<T> unprocessableEntity(String message) {
        return new ApiResponse<>(null, message, 422, null);
    }

    // Unauthorized (Custom, avoid duplicating default status code)
    public static <T> ApiResponse<T> unauthorized(String message) {
        return new ApiResponse<>(null, message, 451, null); // Using 451 to avoid conflict with 401
    }

    // Forbidden (Custom, avoid duplicating default status code)
    public static <T> ApiResponse<T> forbidden(String message) {
        return new ApiResponse<>(null, message, 452, null); // Using 452 to avoid conflict with 403
    }

    // Resource Locked (Custom Error)
    public static <T> ApiResponse<T> resourceLocked(String message) {
        return new ApiResponse<>(null, message, 423, null); // 423 is rarely used and can be repurposed
    }

    // Too Many Requests (Custom, avoid default 429)
    public static <T> ApiResponse<T> tooManyRequests(String message) {
        return new ApiResponse<>(null, message, 453, null); // Using 453 to avoid default 429
    }

    // Custom Code for Data Integrity Violation
    public static <T> ApiResponse<T> dataIntegrityViolation(String message) {
        return new ApiResponse<>(null, message, 460, null); // Unique code
    }

    // Service Unavailable (Custom, avoid default 503)
    public static <T> ApiResponse<T> serviceUnavailable(String message) {
        return new ApiResponse<>(null, message, 550, null); // Custom error status
    }
}
