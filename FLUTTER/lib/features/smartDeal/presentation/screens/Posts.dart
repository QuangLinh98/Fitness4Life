import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/smartDeal/service/QuestionService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'CommentPage.dart';

class Posts extends StatefulWidget {
  final int questionId;
  const Posts({super.key, required this.questionId});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionService = Provider.of<QuestionService>(context, listen: false);
      questionService.fetchQuestionById(widget.questionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionService = Provider.of<QuestionService>(context);
    final question = questionService.selectedQuestion;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Details"),
        backgroundColor: Colors.teal,
      ),
      body: questionService.isFetchingSingle
          ? const Center(child: CircularProgressIndicator())
          : question != null
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề câu hỏi
              Text(
                question.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              // Tên tác giả và thời gian đăng câu hỏi (cùng hàng)
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("By ${question.author}", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const Spacer(),
                  const Icon(Icons.date_range, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(DateFormat.yMMMd().format(question.createdAt), style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
              // Thẻ tag
              Wrap(
                spacing: 8.0,
                children: question.category.map((tag) => Chip(label: Text(tag, style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue)).toList(),
              ),
              const SizedBox(height: 16),
              // Hình ảnh câu hỏi (nếu có)
              if (question.questionImages.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: question.questionImages.first.imageUrl.replaceFirst("localhost", "192.168.1.3"),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              // Nội dung câu hỏi
              Text(
                question.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              // Thông tin bổ sung
              Divider(),
              Row(
                children: [
                  const Icon(Icons.thumb_up, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("${question.upvote}", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  const Icon(Icons.thumb_down, color: Colors.red),
                  const SizedBox(width: 8),
                  Text("${question.downVote}", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  const Icon(Icons.visibility, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("${question.viewCount} views", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 20),
              // 🛑 🛑 🛑hiển thị danh sách comment 🛑 🛑 🛑
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "Comments",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Hiển thị danh sách comment
              CommentPage(questionId: widget.questionId),
            ],
          ),
        ),
      )
          : const Center(child: Text("No data available")),
    );
  }
}
