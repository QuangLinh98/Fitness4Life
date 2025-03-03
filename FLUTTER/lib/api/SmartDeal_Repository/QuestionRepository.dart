import 'package:dio/dio.dart';
import 'package:fitness4life/features/smart_deal/data/models/forum/CreateQuestionDTO.dart';
import 'package:fitness4life/features/smart_deal/data/models/forum/Question.dart';
import 'package:flutter/cupertino.dart';
import '../api_gateway.dart';

class QuestionRepository {
  final ApiGateWayService _apiGateWayService;

  QuestionRepository(this._apiGateWayService);

  Future<List<Question>> getAllQuestion() async {
    try {
      final response = await _apiGateWayService.getData('/deal/forums/questions');

      // In dữ liệu API trả về
      debugPrint("Response từ getAllQuestion API all: ${response.data}");

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

  Future<Response> createQuestion(CreateQuestionDTO question) async {
    try {
      // Chuyển danh sách Uint8List thành MultipartFile
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

      // Gửi dữ liệu qua phương thức postDataWithFormData
      Response response = await _apiGateWayService.postDataWithFormData(url,formData: formData,);

      print("✅ API Response: ${response.data}");
      return response;
    } catch (e) {
      print("❌ Lỗi khi tạo câu hỏi: $e");
      rethrow;
    }
  }



}