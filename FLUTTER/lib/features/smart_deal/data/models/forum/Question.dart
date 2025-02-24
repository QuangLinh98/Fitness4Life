
import 'QuestionImage.dart';

class Question {
  final int id;
  final String author;
  final int authorId;
  final String title;
  final String content;
  final String tag;
  final List<String> category;
  final int viewCount;
  final int upvote;
  final int downVote;
  final String rolePost;
  final String status;
  final List<QuestionImage> questionImages;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.author,
    required this.authorId,
    required this.title,
    required this.content,
    required this.tag,
    required this.category,
    required this.viewCount,
    required this.upvote,
    required this.downVote,
    required this.rolePost,
    required this.status,
    required this.questionImages,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // print("ID question: ${json['id']}"); // In ra trường id
    // print("Author question: ${json['author']}"); // In ra trường author
    // print("AuthorId question: ${json['authorId']}"); // In ra trường authorId
    // print("ViewCount question: ${json['viewCount']}"); // In ra trường viewCount
    // In ra toàn bộ các trường trong json
    json.forEach((key, value) {
      print('$key: $value');
    });
    return Question(
      id: json['id'],
      author: json['author'],
      authorId: json['authorId'],
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
      category: List<String>.from(json['category'] ?? []),
      viewCount: json['viewCount'],
      upvote: json['upvote'],
      downVote: json['downVote'],
      rolePost: json['rolePost'],
      status: json['status'],
      questionImages: (json['questionImage'] as List)
          .map((item) => QuestionImage.fromJson(item))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'][6] * 1000),
    );
  }
}

