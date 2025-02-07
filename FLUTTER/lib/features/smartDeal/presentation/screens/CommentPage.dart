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

    // Sắp xếp danh sách bình luận từ mới nhất đến cũ nhất
    comments.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    // Lọc ra các bình luận cha (parentCommentId == null)
    final parentComments = comments.where((c) => c.parentCommentId == null).toList();

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
            : parentComments.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: parentComments.length,
          itemBuilder: (context, index) {
            return _buildComment(parentComments[index], comments);
          },
        )
            : const Center(child: Text("Chưa có bình luận nào")),
      ],
    );
  }

  Widget _buildComment(comment, List comments) {
    // Lấy toàn bộ comment con của A
    List childComments = _getAllChildComments(comment, comments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _commentCard(comment, isParent: true), // Comment cha (A)

        // Hiển thị toàn bộ comment con (B, C, D, ...) trên cùng 1 hàng
        if (childComments.isNotEmpty)
          Column(
            children: childComments.map((child) => _commentCard(child, isParent: false)).toList(),
          ),
      ],
    );
  }

  List _getAllChildComments(comment, List comments) {
    List allChildren = [];
    void findChildren(dynamic parent) {
      List children = comments.where((c) => c.parentCommentId == parent.id).toList();
      for (var child in children) {
        allChildren.add(child);
        findChildren(child); // Lấy luôn các comment con của con
      }
    }
    findChildren(comment);
    return allChildren;
  }

  Widget _commentCard(comment, {required bool isParent}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: isParent ? 10 : 30), // Chỉ thụt lề comment con cấp 1
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
            const SizedBox(height: 5),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.reply, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      showReplyForm[comment.id] = !(showReplyForm[comment.id] ?? false);
                    });
                  },
                ),
                const Text("Trả lời", style: TextStyle(color: Colors.blue)),
              ],
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
}
