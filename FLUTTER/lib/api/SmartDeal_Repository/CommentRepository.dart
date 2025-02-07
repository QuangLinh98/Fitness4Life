import 'package:fitness4life/features/smartDeal/data/models/forum/GetComment.dart';
import '../../features/smartDeal/data/models/forum/Comment.dart';
import '../api_gateway.dart';

class CommentRepository{

  final ApiGateWayService _apiGateWayService;

  CommentRepository(this._apiGateWayService);

  Future<List<GetComment>> getCommentFlowQuestion(int questionId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/question/$questionId/comment');

      if (response.data != null && response.data is List) {
        List<dynamic> dataList = response.data;
        List<GetComment?> comments = dataList.map((json) {
          try {
            // Kiểm tra `createdAt` nếu không đúng kiểu List thì gán giá trị mặc định
            List<int>? createdAt = json['createdAt'] is List
                ? List<int>.from(json['createdAt'])
                : null;

            // Kiểm tra và chuyển đổi danh sách `replies`
            List<dynamic> repliesList = json['replies'] is List ? json['replies'] : [];

            GetComment comment = GetComment.fromJson({
              ...json,
              'createdAt': createdAt, // Cập nhật kiểu dữ liệu
              'replies': repliesList, // Đảm bảo luôn là List
            });

            return comment;
          } catch (e) {
            print("❌ Lỗi chuyển đổi comment: $e");
            return null;
          }
        }).where((item) => item != null).toList();

        return comments.cast<GetComment>();
      } else {
        throw Exception("Invalid response structure: Expected a List.");
      }
    } catch (e) {
      throw Exception("Failed to fetch comments. Please try again later.");
    }
  }

  Future<bool> createComment(Comment comment) async {
    try {
      const url = '/deal/forums/comments/create';

      final payload = {
        "userId": comment.userId,
        "userName": comment.userName,
        "questionId": comment.questionId,
        "parentCommentId": comment.parentCommentId,
        "content": comment.content,
      };

      final response = await _apiGateWayService.postData(url, data: payload);
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        print("lỗi 400 rồi");
        return false;
      } else if (response.statusCode == 401) {
        print("lỗi 401 rồi");
        return false;
      } else if (response.statusCode == 402) {
        print("lỗi 402 rồi");
        return false;
      } else {
        print( "Failed to create comment: ${response.data}");
        return false;
      }
    } catch (e) {
      return false;
    }
  }




}
