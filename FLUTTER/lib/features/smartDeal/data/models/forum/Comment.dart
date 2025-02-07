class Comment {
  final int userId;
  final String userName;
  final int questionId;
  final int? parentCommentId;
  final String content;

  Comment({
    required this.userId,
    required this.userName,
    required this.questionId,
    this.parentCommentId,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'],
      userName: json['userName'],
      questionId: json['questionId'],
      parentCommentId: json['parentCommentId'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'questionId': questionId,
      'parentCommentId': parentCommentId,
      'content': content,
    };
  }
}
