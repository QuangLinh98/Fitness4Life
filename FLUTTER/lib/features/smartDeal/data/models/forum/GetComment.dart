class GetComment {
  int? id;
  int? userId;
  String? userName;
  String? content;
  int? questionId; // Chỉ lấy ID của question
  int? blogId; // Chỉ lấy ID của blog
  int? parentCommentId; // Chỉ lấy ID của comment cha
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isPublished;
  List<GetComment>? replies;

  GetComment({
    this.id,
    this.userId,
    this.userName,
    this.content,
    this.questionId,
    this.blogId,
    this.parentCommentId,
    this.createdAt,
    this.updatedAt,
    this.isPublished,
    this.replies,
  });

  // Chuyển từ JSON thành GetComment
  factory GetComment.fromJson(Map<String, dynamic> json) {
    return GetComment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'],
      questionId: json['questionId'],
      blogId: json['blogId'],
      parentCommentId: json['parentCommentId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPublished: json['isPublished'],
      replies: (json['replies'] as List?)?.map((e) => GetComment.fromJson(e)).toList(),
    );
  }

  // Chuyển từ GetComment thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'questionId': questionId,
      'blogId': blogId,
      'parentCommentId': parentCommentId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPublished': isPublished,
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}
