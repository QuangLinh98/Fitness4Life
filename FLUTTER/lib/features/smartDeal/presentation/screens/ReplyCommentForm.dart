import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/smartDeal/service/CommentService.dart';
import 'package:fitness4life/features/smartDeal/data/models/forum/Comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReplyCommentForm extends StatefulWidget {
  final int questionId;
  final int parentCommentId; // ID của bình luận cha

  const ReplyCommentForm({
    Key? key,
    required this.questionId,
    required this.parentCommentId,
  }) : super(key: key);

  @override
  _ReplyCommentFormState createState() => _ReplyCommentFormState();
}

class _ReplyCommentFormState extends State<ReplyCommentForm> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitReply() async {

    if (_contentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final commentService = Provider.of<CommentService>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('user_fullname');
      int? userId = prefs.getInt('user_id');

      if (userName == null || userId == null) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final replyComment = Comment(
        userId: userId,
        userName: userName,
        questionId: widget.questionId,
        parentCommentId: widget.parentCommentId,
        content: _contentController.text.trim(),
      );

      bool success = await commentService.CreateComment(replyComment);

      if (success) {
        _contentController.clear();

        setState(() {
          _isSubmitting = false;
        });
      } else {
        print("Gửi bình luận thất bại!");
      }
    } catch (e) {
      print("Lỗi khi gửi bình luận: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _contentController,
          decoration: InputDecoration(
            hintText: "Nhập câu trả lời...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: Colors.teal),
              onPressed: _isSubmitting ? null : _submitReply,
            ),
          ),
          maxLines: 3,
        ),
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
