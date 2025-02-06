import 'package:fitness4life/features/smartDeal/data/models/forum/GetComment.dart';
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
}
