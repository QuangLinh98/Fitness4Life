package fpt.aptech.bookingservice.configs;

import com.paypal.base.rest.APIContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class PayPalConfig {
    @Value("${paypal.client.id}")
    private String clientId;

    @Value("${paypal.client.secret}")
    private String clientSecret;

    @Value("${paypal.mode}")
    private String mode;

    // @Bean cho biết rằng phương thức này sẽ trả về một bean mà Spring sẽ quản lý.
    // Phương thức này tạo ra và trả về một đối tượng APIContext,
    // sử dụng các giá trị đã được cấu hình ở trên.
    @Bean
    public APIContext apiContext() {
        return new APIContext(clientId, clientSecret, mode);
    }
}
