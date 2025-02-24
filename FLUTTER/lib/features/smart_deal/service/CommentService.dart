import 'package:fitness4life/features/smart_deal/data/models/forum/Comment.dart';
import 'package:fitness4life/features/smart_deal/data/models/forum/GetComment.dart';
import 'package:flutter/cupertino.dart';

import '../../../api/SmartDeal_Repository/CommentRepository.dart';

class CommentService extends ChangeNotifier {
  final CommentRepository _commentRepository;

  List<GetComment> comments = [];
  bool isLoading = false;

  CommentService(this._commentRepository);

  // Get all comment flow question
  Future<void> fetchCommentFlowQuestion(int questionId) async {
    isLoading = true;
    notifyListeners();
    try {
      comments = await _commentRepository.getCommentFlowQuestion(questionId);
      debugPrint("Fetched comments $questionId: $comments");
    } catch (e) {
      print("Error fetching comments by ID: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> CreateComment(Comment comment) async {
    try {
      bool success = await _commentRepository.createComment(comment);
      if (success) {
        await Future.delayed(Duration(milliseconds: 1000)); // Đợi 2 giây trước khi làm mới
        await fetchCommentFlowQuestion(comment.questionId!); // Làm mới danh sách bình luận
      }
      return success;
    } catch (e) {
      print("Error creating comment: $e");
      return false;
    }
  }



}