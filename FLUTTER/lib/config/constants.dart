//const String SERVER_IP = "192.168.1.45"; // Đổi IP dễ dàng khi cần
const String SERVER_IP = "172.29.160.1"; // Đổi IP dễ dàng khi cần

/// Hàm thay thế "localhost" bằng SERVER_IP
String getFullImageUrl(String url) {
  return url.replaceFirst("localhost", SERVER_IP);
}
