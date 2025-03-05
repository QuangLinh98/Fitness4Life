import 'package:fitness4life/features/smart_deal/data/models/forum/Comment.dart';
import 'package:fitness4life/features/smart_deal/service/CommentService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCommentForm extends StatefulWidget {
  final int questionId;

  const CreateCommentForm({Key? key, required this.questionId}) : super(key: key);

  @override
  _CreateCommentFormState createState() => _CreateCommentFormState();
}

class _CreateCommentFormState extends State<CreateCommentForm> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitComment() async {
    if (_contentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final commentService = Provider.of<CommentService>(context, listen: false);
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);

    String? userName = userInfo.userName;
    int? userId = userInfo.userId;

    if (userId == null || userName == null) {
      print("Lỗi: userId hoặc userName bị null");
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final comment = Comment(
      userId: userId,
      userName: userName,
      questionId: widget.questionId,
      content: _contentController.text.trim(),
    );
    print("Có userId trong comment không ta: ${userId}");

    print("Có data trong comment không ta: ${comment}");

    bool success = await commentService.CreateComment(comment);

    if (success) {
      _contentController.clear(); // Xóa nội dung ô nhập sau khi gửi thành công
    }

    setState(() {
      _isSubmitting = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        TextField(
          controller: _contentController,
          decoration: InputDecoration(
            hintText: "Enter comment...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(Icons.send, color: Colors.teal),
              onPressed: _isSubmitting ? null : _submitComment,
            ),
          ),
          maxLines: 3,
        ),
        if (_isSubmitting) const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}