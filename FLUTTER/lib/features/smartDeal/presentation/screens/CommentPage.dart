import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/smartDeal/service/CommentService.dart';
import 'package:intl/intl.dart';

class CommentPage extends StatefulWidget {
  final int questionId;
  const CommentPage({Key? key, required this.questionId}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commentService = Provider.of<CommentService>(context, listen: false);
      commentService.fetchCommentFlowQuestion(widget.questionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentService = Provider.of<CommentService>(context);
    final comments = commentService.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Bình luận",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        commentService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : comments.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return _buildComment(comments[index]);
          },
        )
            : const Center(child: Text("Chưa có bình luận nào")),
      ],
    );
  }

  Widget _buildComment(comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (comment.replies.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                "Phản hồi:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: comment.replies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 5),
                    child: _buildComment(comment.replies[index]),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
