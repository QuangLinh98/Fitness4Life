import 'package:dio/dio.dart';
import 'package:fitness4life/features/smartDeal/data/models/forum/CreateQuestionDTO.dart';
import 'package:fitness4life/features/smartDeal/data/models/forum/Question.dart';
import 'package:flutter/cupertino.dart';
import '../api_gateway.dart';

class QuestionRepository {
  final ApiGateWayService _apiGateWayService;

  QuestionRepository(this._apiGateWayService);

  Future<List<Question>> getAllQuestion() async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/questions');
      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];
        List<Question?> questions = dataList.map((json) {
          try {
            Question question = Question.fromJson(json);
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

      if (response.data != null && response.data['data'] != null) {
        try {
          Question question = Question.fromJson(response.data['data']);
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

  Future<Response> createQuestion(CreateQuestionDTO question) async {
    try {
      List<MultipartFile> images = await Future.wait(
        question.imageQuestionUrl.map((image) async {
          return MultipartFile.fromBytes(image, filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        }),
      );
      final url = '/deal/forums/questions/create';
      // Tạo FormData
      FormData formData = FormData.fromMap({
        'authorId': question.authorId,
        'author': question.author,
        'title': question.title,
        'content': question.content,
        'tag': question.tag,
        'status': question.status,
        'category': question.category,
        'rolePost': question.rolePost,
        'imageQuestionUrl': images,
      });
      Response response = await _apiGateWayService.postDataWithFormData(url,formData: formData,);
      debugPrint("✅ API Response: ${response.data}");
      return response;
    } catch (e) {
      print("❌ Lỗi khi tạo câu hỏi: $e");
      rethrow;
    }
  }

  // Future<bool> voteQuestion(int questionId, int userId, String voteType) async {
  //   try {
  //     // Tạo URL với query parameters
  //     final url = '/deal/forums/$questionId/vote?userId=$userId&voteType=$voteType';
  //
  //     // Gửi request POST
  //     await _apiGateWayService.postData(url);
  //
  //     debugPrint("✅ Vote thành công");
  //     return true;
  //   } catch (e) {
  //     print("❌ Lỗi khi vote câu hỏi: $e");
  //     rethrow;
  //   }
  // }



}
