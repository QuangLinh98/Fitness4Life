import 'package:flutter/material.dart';

enum PackageName {
  CLASSIC,
  CLASSIC_PLUS,
  PRESIDENT,
  ROYAL,
  SIGNATURE,
}

class WorkoutPackage {
  final int id;
  final PackageName packageName;
  final String description;
  final int durationMonth;
  final double price;
  final DateTime createAt;
  final DateTime updateAt;

  WorkoutPackage({
    required this.id,
    required this.packageName,
    required this.description,
    required this.durationMonth,
    required this.price,
    required this.createAt,
    required this.updateAt,
  });

  // Chuyển đổi từ JSON sang Object
  factory WorkoutPackage.fromJson(Map<String, dynamic> json) {
    return WorkoutPackage(
      id: json['id'],
      packageName: PackageName.values.firstWhere(
            (e) => e.toString().split('.').last == json['packageName'],
        orElse: () => PackageName.CLASSIC, // Mặc định CLASSIC nếu không tìm thấy
      ),
      description: json['description'],
      durationMonth: json['durationMonth'],
      price: json['price'],
      createAt: (json['createAt'] is List)
          ? DateTime(
        json['createAt'][0],
        json['createAt'][1],
        json['createAt'][2],
        json['createAt'][3],
        json['createAt'][4],
        json['createAt'][5],
        json['createAt'][6],
      )
          : DateTime.parse(json['createAt']),
      updateAt: (json['updateAt'] is List)
          ? DateTime(
        json['updateAt'][0],
        json['updateAt'][1],
        json['updateAt'][2],
        json['updateAt'][3],
        json['updateAt'][4],
        json['updateAt'][5],
        json['updateAt'][6],
      )
          : (json['updateAt'] != null ? DateTime.parse(json['updateAt']) : DateTime.now()),
    );
  }

  // Chuyển đổi từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "packageName": packageName.toString().split('.').last,
      "description": description,
      "durationMonth": durationMonth,
      "price": price,
      "createAt": createAt.toIso8601String(),
      "updateAt": updateAt.toIso8601String(),
    };
  }
}