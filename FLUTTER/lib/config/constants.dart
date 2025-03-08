
const String SERVER_IP = "173.16.16.182"; // Đổi IP dễ dàng khi cần

/// Hàm thay thế "localhost" bằng SERVER_IP
String getFullImageUrl(String url) {
  return url.replaceFirst("localhost", SERVER_IP);
}
