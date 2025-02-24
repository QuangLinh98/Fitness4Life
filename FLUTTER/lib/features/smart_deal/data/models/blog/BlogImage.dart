class BlogImage {
  final int id;
  final String imageUrl;

  BlogImage({required this.id, required this.imageUrl});

  factory BlogImage.fromJson(Map<String, dynamic> json) {
    return BlogImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }
}