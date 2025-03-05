class QR {
  final int id;
  final int bookingRoomId;
  final String qrCodeUrl;
  final String qrCodeStatus;
  final DateTime createdAt;

  QR({
    required this.id,
    required this.bookingRoomId,
    required this.qrCodeUrl,
    required this.qrCodeStatus,
    required this.createdAt,
  });

  // Parse JSON từ API
  factory QR.fromJson(Map<String, dynamic> json) {
    return QR(
      id: json['id'] ?? 0,
      bookingRoomId: json['bookingRoom'] is int
          ? json['bookingRoom'] // Nếu bookingRoom là int
          : json['bookingRoom']['id'] ?? 0, // Nếu bookingRoom là Map
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      qrCodeStatus: json['qrCodeStatus'] ?? 'unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Chuyển đối tượng QR thành Map để gửi qua API hoặc lưu trữ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingRoom': {
        'id': bookingRoomId,  // Nếu có mối quan hệ với bookingRoom
      },
      'qrCodeUrl': qrCodeUrl,
      'qrCodeStatus': qrCodeStatus,
      'createdAt': createdAt.toIso8601String(), // Chuyển DateTime thành chuỗi ISO
    };
  }

}
