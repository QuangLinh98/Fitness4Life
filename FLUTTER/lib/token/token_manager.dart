import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refreshToken';

  // Lưu token vào SecureStorage
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      //print("Tokens saved securely.");

      // Xác minh lưu trữ
      final savedAccessToken = await _storage.read(key: _accessTokenKey);
      final savedRefreshToken = await _storage.read(key: _refreshTokenKey);
      //print("Verification - AccessToken: $savedAccessToken, RefreshToken: $savedRefreshToken");
    } catch (e) {
      print("Failed to save tokens: $e");
    }
  }

  // Lấy access token từ SecureStorage
  static Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      print("Retrieved AccessToken=$token");
      return token;
    } catch (e,stackTrace) {
      print("Failed to retrieve token: $e");
      print("StackTrace: $stackTrace");
      return null;
    }
  }

  //Kiểm tra tất cả các token
  static Future<Map<String, String?>> getAllTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } catch (e) {
      print("Failed to retrieve tokens: $e");
      return {};
    }
  }

  // Lấy refresh token từ SecureStorage
  static Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    return token;
  }

  // Xóa token khỏi SecureStorage
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    print("Tokens cleared securely.");
  }

  //Trích xuất thông tin trong token
  void decodeToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    print("Decoded Token: $decodedToken");
  }

  // Kiểm tra token có hợp lệ hay không (chưa hết hạn)
  static bool isTokenValid(String token) {
    return !JwtDecoder.isExpired(token);
  }

  // Lấy thời gian hết hạn của token
  static DateTime? getTokenExpiration(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print("Error getting token expiration date: $e");
      return null;
    }
  }
}