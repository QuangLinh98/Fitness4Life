import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/smartDeal/service/CommentService.dart';
import 'package:intl/intl.dart';

import 'CreateCommentForm.dart';
import 'ReplyCommentForm.dart';

class CommentPage extends StatefulWidget {
  final int questionId;
  const CommentPage({Key? key, required this.questionId}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  Map<int, bool> showReplyForm = {};
  bool showAll = false;
  static const int commentLimit = 5;
  static const int maxLineLength = 50; // Giới hạn số ký tự trước khi xuống hàng

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

    comments.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    final parentComments = comments.where((c) => c.parentCommentId == null).toList();

    List allComments = [];
    for (var parent in parentComments) {
      allComments.add(parent);
      allComments.addAll(_getAllChildComments(parent, comments));
    }

    bool hasMoreComments = allComments.length > commentLimit;
    List displayedComments = showAll ? allComments : allComments.take(commentLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Bình luận",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        CreateCommentForm(questionId: widget.questionId),
        const SizedBox(height: 10),
        commentService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : displayedComments.isNotEmpty
            ? Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: displayedComments.length,
              itemBuilder: (context, index) {
                return _commentCard(displayedComments[index], comments);
              },
            ),
            if (hasMoreComments)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAll = !showAll;
                  });
                },
                child: Text(showAll ? "Thu hồi" : "Xem thêm"),
              ),
          ],
        )
            : const Center(child: Text("Chưa có bình luận nào")),
      ],
    );
  }

  List _getAllChildComments(comment, List comments) {
    List allChildren = [];
    void findChildren(dynamic parent) {
      List children = comments.where((c) => c.parentCommentId == parent.id).toList();
      for (var child in children) {
        allChildren.add(child);
        findChildren(child);
      }
    }
    findChildren(comment);
    return allChildren;
  }

  Widget _commentCard(comment, List comments) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: comment.parentCommentId == null ? 10 : 30),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('   yyyy-MM-dd HH:mm').format(comment.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _formatCommentText(comment.content),
              style: const TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showReplyForm[comment.id] = !(showReplyForm[comment.id] ?? false);
                });
              },
              child: const Text("   Reply", style: TextStyle(color: Colors.blue)),
            ),
            if (showReplyForm[comment.id] ?? false)
              ReplyCommentForm(
                questionId: widget.questionId,
                parentCommentId: comment.id,
              ),
          ],
        ),
      ),
    );
  }

  String _formatCommentText(String text) {
    List<String> words = text.split(' ');
    String formattedText = '';
    String currentLine = '';
    for (String word in words) {
      if ((currentLine + ' ' + word).trim().length > maxLineLength) {
        formattedText += currentLine.trim() + '\n';
        currentLine = word;
      } else {
        currentLine += ' ' + word;
      }
    }
    formattedText += currentLine.trim();
    return formattedText;
  }
}
