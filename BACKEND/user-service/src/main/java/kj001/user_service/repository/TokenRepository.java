package kj001.user_service.repository;

import kj001.user_service.models.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface TokenRepository extends JpaRepository<Token, Integer> {

    @Query("""
            select t from Token t inner join User u on t.user.id = u.id
            where t.user.id = :userId and t.loggedOut = false
            """)
    List<Token> findAllAccessTokensByUser(Long userId); //Tìm tất cả các AccessToken chưa bị đăng xuất thuộc về 1 user cụ thể

    Optional<Token> findByAccessToken(String token);  //Tìm một token trong cơ sở dữ liệu dựa trên giá trị của Access Token.

    Optional<Token> findByRefreshToken(String token);  //Tìm một token trong cơ sở dữ liệu dựa trên giá trị của Refresh Token.
}
