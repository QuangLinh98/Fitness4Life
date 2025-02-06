class QuestionImage {
  final int id;
  final String imageUrl;

  QuestionImage({required this.id, required this.imageUrl});

  factory QuestionImage.fromJson(Map<String, dynamic> json) {
    return QuestionImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }
}
