
import 'BlogImage.dart';

class Blog {
  int? id;
  String authorName;
  String title;
  String content;
  String category;
  String tags;
  DateTime createdAt;
  bool isPublished;
  List<BlogImage> thumbnailUrl;

  Blog({
    this.id,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.isPublished,
    required this.thumbnailUrl,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      authorName: json['authorName'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      tags: json['tags'],
      createdAt: DateTime(
          json['createdAt'][0],  // Năm
          json['createdAt'][1],  // Tháng
          json['createdAt'][2],  // Ngày
          json['createdAt'][3],  // Giờ
          json['createdAt'][4],  // Phút
          json['createdAt'][5],  // Giây
          (json['createdAt'][6] / 1000000).round()  // Microseconds
      ),
      isPublished: json['isPublished'],
      thumbnailUrl: (json['thumbnailUrl'] as List<dynamic>?)
          ?.map((item) => BlogImage.fromJson(item))
          .toList() ?? [],  // Nếu null, trả về danh sách rỗng
    );
  }

}
