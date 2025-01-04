package kj001.user_service.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public class AuthenticationResponse {
    @JsonProperty("access_token")
    private String accessToken;  //Là Access Token JWT.Sử dụng để xác thực người dùng trong các API yêu cầu bảo mật.

    @JsonProperty("refresh_token")
    private String refreshToken;  //Là Refresh Token JWT.Sử dụng để tạo Access Token mới khi Access Token hiện tại hết hạn.

    @JsonProperty("message")
    private String message;   //Là thông báo phản hồi từ server bao gồm các thông tin như trạng thái thành công hay lỗi.

    //Contructor sử dụng để khởi tạo đối tượng
    public AuthenticationResponse(String accessToken, String refreshToken, String message) {
        this.accessToken = accessToken;
        this.message = message;
        this.refreshToken = refreshToken;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public String getMessage() {
        return message;
    }
}
