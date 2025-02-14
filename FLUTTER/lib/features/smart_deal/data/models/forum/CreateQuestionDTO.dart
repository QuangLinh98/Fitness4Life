import 'dart:typed_data';

class CreateQuestionDTO {
  final int authorId;
  final String author;
  final String title;
  final String content;
  final String tag;
  final String status;
  final List<String> category;
  final String rolePost;
  final List<Uint8List> imageQuestionUrl;

  CreateQuestionDTO({
    required this.authorId,
    required this.author,
    required this.title,
    required this.content,
    required this.tag,
    required this.status,
    required this.category,
    required this.rolePost,
    required this.imageQuestionUrl,
  });

  factory CreateQuestionDTO.fromJson(Map<String, dynamic> json) {
    return CreateQuestionDTO(
      authorId: json['authorId'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
      status: json['status'],
      category: List<String>.from(json['category']),
      rolePost: json['rolePost'],
      imageQuestionUrl: (json['imageQuestionUrl'] as List<dynamic>).map((e) => Uint8List.fromList(e.cast<int>())).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'author': author,
      'title': title,
      'content': content,
      'tag': tag,
      'status': status,
      'category': category,
      'rolePost': rolePost,
      'imageQuestionUrl': imageQuestionUrl.map((e) => e.toList()).toList(),
    };
  }
}