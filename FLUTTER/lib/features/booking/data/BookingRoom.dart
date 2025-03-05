import 'dart:convert';

import 'package:fitness4life/features/booking/data/QR.dart';

class BookingRoom {
  int? id;
  int? userId;
  String? userName;
  int? roomId;
  String? roomName;
  DateTime? bookingDate;
  String? status;
  DateTime? createAt;
  List<QR>? qrCodes;

  BookingRoom({
    this.id,
    this.userId,
    this.userName,
    this.roomId,
    this.roomName,
    this.bookingDate,
    this.status,
    this.createAt,
    this.qrCodes,
  });

  // Tạo từ JSON
  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      roomId: json['roomId'],
      roomName: json['roomName'],
      //bookingDate: json['bookingDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['bookingDate'][6] * 1000) : null,
      bookingDate: json['bookingDate'] != null
          ? DateTime(
        json['bookingDate'][0], // Năm
        json['bookingDate'][1], // Tháng
        json['bookingDate'][2], // Ngày
        json['bookingDate'][3], // Giờ
        json['bookingDate'][4], // Phút
        json['bookingDate'][5], // Giây
      )
          : null,
      status: json['status'],
      createAt: json['createAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createAt'][6] * 1000) : null,
      qrCodes: json['qrCodes'] != null
          ? (json['qrCodes'] as List)
          .map((qrCodeJson) => QR.fromJson(qrCodeJson))
          .toList()
          : null,
    );
  }

  // Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'roomId': roomId,
      'roomName': roomName,
      'bookingDate': bookingDate != null
          ? [
        bookingDate!.year,
        bookingDate!.month,
        bookingDate!.day,
        bookingDate!.hour,
        bookingDate!.minute,
        bookingDate!.second,
      ]
          : null,
      'status': status,
      'createAt': createAt?.toIso8601String(),
      'qrCodes': qrCodes?.map((qrCode) => qrCode.toJson()).toList(), // Chuyển qrCodes thành JSON

    };
  }
}
