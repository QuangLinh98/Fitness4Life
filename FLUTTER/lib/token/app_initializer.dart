import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/token/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

/// Kiểm tra trạng thái đăng nhập để quyết định màn hình khởi động
Future<String> determineInitialRoute(BuildContext context) async {
  try {
    final accessToken = await TokenManager.getAccessToken();

    if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
      // Token hợp lệ -> Giải mã token
      final jwtPayload = JwtDecoder.decode(accessToken);
      print("Decoded JWT Payload: $jwtPayload");

      // Lấy thông tin userName từ payload (key có thể khác tùy server của bạn)
      final userName = jwtPayload['fullName'] ?? 'Unknown User';
      final userId = jwtPayload['id'] ?? 0; // ✅ Lấy userId từ JWT

      print("✅ Extracted userId: $userId, userName: $userName");

      // Cập nhật UserInfoProvider
      final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
      userInfoProvider.setUserName(userName);
      userInfoProvider.setUserId(userId);

      print("✅ Extracted userName: $userName");
      print("✅ Extracted userId 2: $userId");

      // Token hợp lệ -> Chuyển đến PageManager
      return '/pageManager';
    } else {
      // Token không tồn tại hoặc đã hết hạn -> Yêu cầu đăng nhập
      return '/login';
    }
  } catch (e) {
    print("Error determining initial route: $e");
    // Nếu xảy ra lỗi, mặc định chuyển đến màn hình đăng nhập
    return '/login';
  }
}