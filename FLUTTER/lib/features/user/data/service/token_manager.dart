import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _accessTokenKey = 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJuZ3V5ZW5saW5oYWs0QGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImZ1bGxOYW1lIjoiVHJhbiBOaGFuIEFuIiwiaWF0IjoxNzM2OTMyNTg1LCJleHAiOjE3MzcwMTg5ODV9.pp_twud-YaiJKC2gmTluEBNEz4GcWts5VNiJTpTgurLNvul2K-D5KFshofdQyIu0';
  static const _refreshTokenKey = 'refreshToken';

  // Lưu token vào SharedPreferences
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Lấy access token
  static Future<String?> getAccessToken() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(_accessTokenKey);
    return _accessTokenKey;
  }

  // Lấy refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Xóa token
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}