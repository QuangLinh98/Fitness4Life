import 'package:fitness4life/features/smartDeal/data/models/forum/GetComment.dart';
import 'package:flutter/cupertino.dart';

import '../api_gateway.dart';

class CommentRepository{

  final ApiGateWayService _apiGateWayService;

  CommentRepository(this._apiGateWayService);


  Future<List<GetComment>> getCommentFlowQuestion(int questionId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/question/$questionId/comment');

      // In dữ liệu API trả về
      debugPrint("Response từ API getCommentFlowQuestion: ${response.data}");

      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];

        List<GetComment?> comments = dataList.map((json) {
          try {
            GetComment comment = GetComment.fromJson(json); // Chuyển đổi thành đối tượng Question

            // ✅ Log dữ liệu đã chuyển đổi
            debugPrint("✅ Đã parse all: $comment");

            return comment;
          } catch (e) {
            print("❌ Lỗi chuyển đổi comment all: $e");
            return null;
          }
        }).where((item) => item != null).toList();

        return comments.cast<GetComment>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách comment từ câu hỏi: $e");
      throw Exception("Failed to fetch questions. Please try again later.");
    }
  }

}