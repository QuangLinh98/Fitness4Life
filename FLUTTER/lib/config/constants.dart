const String SERVER_IP = "192.168.1.3"; // Đổi IP dễ dàng khi cần

/// Hàm thay thế "localhost" bằng SERVER_IP
String getFullImageUrl(String url) {
  return url.replaceFirst("localhost", SERVER_IP);
}
