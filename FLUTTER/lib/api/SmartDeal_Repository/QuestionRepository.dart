import 'package:fitness4life/features/smartDeal/data/models/forum/Question.dart';
import 'package:flutter/cupertino.dart';
import '../api_gateway.dart';

class QuestionRepository {
  final ApiGateWayService _apiGateWayService;

  QuestionRepository(this._apiGateWayService);

  Future<List<Question>> getAllQuestion() async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/questions');

      // In dữ liệu API trả về
      debugPrint("Response từ API all: ${response.data}");

      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];

        List<Question?> questions = dataList.map((json) {
          try {
            Question question = Question.fromJson(json); // Chuyển đổi thành đối tượng Question

            // ✅ Log dữ liệu đã chuyển đổi
            debugPrint("✅ Đã parse all: $question");

            return question;
          } catch (e) {
            print("❌ Lỗi chuyển đổi Question all: $e");
            return null;
          }
        }).where((item) => item != null).toList();

        return questions.cast<Question>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách câu hỏi: $e");
      throw Exception("Failed to fetch questions. Please try again later.");
    }
  }


  Future<Question?> getQuestionById(int questionId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/questions/getOne/$questionId');

      debugPrint("Response từ API one ($questionId): ${response.data}");

      if (response.data != null && response.data['data'] != null) {
        try {
          Question question = Question.fromJson(response.data['data']);

          // ✅ Log dữ liệu đã chuyển đổi
          debugPrint("✅ Đã parse by id: $question");

          return question;
        } catch (e) {
          print("❌ Lỗi chuyển đổi Question one: $e");
          return null;
        }
      } else {
        throw Exception("Invalid response structure or no data found.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy câu hỏi $questionId: $e");
      throw Exception("Failed to fetch question. Please try again later.");
    }
  }

  // Future<bool> voteQuestion(int questionId, int userId, String voteType) async {
  //   try {
  //     final response = await _apiGateWayService.postData(
  //       '/deal/forums/questions/$questionId/vote',
  //       data: {
  //         'userId': userId,
  //         'voteType': voteType, // Giá trị này có thể là "UPVOTE" hoặc "DOWNVOTE"
  //       },
  //     );
  //
  //     debugPrint("Response từ API vote ($questionId): ${response.data}");
  //
  //     if (response.statusCode == 200) {
  //       return true; // Xử lý vote thành công
  //     } else {
  //       throw Exception("Vote failed with status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Lỗi khi vote câu hỏi $questionId: $e");
  //     return false;
  //   }
  // }


}
