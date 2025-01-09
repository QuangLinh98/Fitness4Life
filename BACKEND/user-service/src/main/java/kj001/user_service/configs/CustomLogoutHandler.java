package kj001.user_service.configs;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kj001.user_service.models.Token;
import kj001.user_service.repository.TokenRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutHandler;

@Configuration
public class CustomLogoutHandler implements LogoutHandler {

    private final TokenRepository tokenRepository;

    public CustomLogoutHandler(TokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    @Override
    public void logout(HttpServletRequest request,
                       HttpServletResponse response,
                       Authentication authentication) {
        String authHeader = request.getHeader("Authorization");

        if(authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("Authorization header is missing or invalid.");
            return;
        }

        String token = authHeader.substring(7);
        System.out.println("Token for logout: " + token);
        Token storedToken = tokenRepository.findByAccessToken(token).orElse(null);
        System.out.println("Stored token: " + storedToken);

        if(storedToken != null) {
            storedToken.setLoggedOut(true);
            tokenRepository.save(storedToken);
            System.out.println("Token has been logged out successfully.");

        }
    }
}
