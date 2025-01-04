package kj001.user_service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

public class JwtValidator {
    public static void main(String[] args) {
        String secretKey = "4bb6d1dfbafb64a681139d1586b6f1160d18159afd57c8c79136d7490630407c";
        String token = "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJuZ3V5ZW5saW5oYWs0QGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImZ1bGxOYW1lIjoiTmd1eWVuIFF1YW5nIExpbmgiLCJpYXQiOjE3MzU5NTg4NDksImV4cCI6MTczNjA0NTI0OX0.7ggqd_sZL7BTEwDpnBFmJ-ejfp4zXwDuEeXFMDK5-OWg_nxtumGYguxy3frvSSPM";

        try {
            SecretKey key = Keys.hmacShaKeyFor(Decoders.BASE64URL.decode(secretKey));

            Claims claims = Jwts.parser()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            System.out.println("JWT hợp lệ, claims: " + claims);
        } catch (Exception e) {
            System.err.println("JWT không hợp lệ: " + e.getMessage());
        }
    }
}
