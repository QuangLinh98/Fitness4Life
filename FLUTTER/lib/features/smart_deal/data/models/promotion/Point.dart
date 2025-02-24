class Point {
  final int userId;
  final int totalPoints;

  Point({required this.userId, required this.totalPoints});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      userId: json['userId'] as int,
      totalPoints: json['totalPoints'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
    };
  }
}