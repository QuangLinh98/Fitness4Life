import 'dart:convert';

class OTP {
  final int? id;
  final String email;
  final String subject;
  final String content;
  final String otpCode;
  final DateTime expiryTime;
  final bool isUsed;
  final int sendAttempts;
  final DateTime? lastSend;

  OTP({
    this.id,
    required this.email,
    required this.subject,
    required this.content,
    required this.otpCode,
    required this.expiryTime,
    required this.isUsed,
    required this.sendAttempts,
    this.lastSend,
  });

  // Chuyển từ JSON sang OTP object
  factory OTP.fromJson(Map<String, dynamic> json) {
    return OTP(
      id: json['id'],
      email: json['email'],
      subject: json['subject'],
      content: json['content'],
      otpCode: json['otpCode'],
      expiryTime: DateTime.parse(json['expiryTime']),
      isUsed: json['isUsed'],
      sendAttempts: json['sendAttempts'],
      lastSend: json['lastSend'] != null ? DateTime.parse(json['lastSend']) : null,
    );
  }

  // Chuyển từ OTP object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'subject': subject,
      'content': content,
      'otpCode': otpCode,
      'expiryTime': expiryTime.toIso8601String(),
      'isUsed': isUsed,
      'sendAttempts': sendAttempts,
      'lastSend': lastSend?.toIso8601String(),
    };
  }
}
