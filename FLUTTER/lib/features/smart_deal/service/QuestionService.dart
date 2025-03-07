import 'package:fitness4life/api/SmartDeal_Repository/QuestionRepository.dart';
import 'package:fitness4life/features/smart_deal/data/models/forum/CreateQuestionDTO.dart';
import 'package:fitness4life/features/smart_deal/data/models/forum/Question.dart';
import 'package:flutter/cupertino.dart';

import '../data/models/forum/CreateQuestionDTO.dart';

class QuestionService extends ChangeNotifier {
  final QuestionRepository _questionRepository;

  List<Question> questions = [];
  Question? selectedQuestion; // Lưu trữ câu hỏi được lấy theo ID
  bool isLoading = false;
  bool isFetchingSingle = false; // Biến trạng thái khi lấy 1 câu hỏi

  QuestionService(this._questionRepository);


  Future<bool> CreateQuestion(CreateQuestionDTO newQuestion) async {
    isFetchingSingle = true;
    notifyListeners();
    try {
      await _questionRepository.createQuestion(newQuestion);
      await fetchQuestions();
      return true;
    } catch (e) {
      print("Error create question: $e");
      return false;
    } finally {
      isFetchingSingle = false;
      notifyListeners();
    }
  }
  // Get all questions
  Future<void> fetchQuestions() async {
    isLoading = true;
    notifyListeners();
    try {
      questions = await _questionRepository.getAllQuestion();
      debugPrint("Fetched questions: $questions");
    } catch (e) {
      print("Error fetching questions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Get question by ID
  Future<void> fetchQuestionById(int questionId) async {
    isFetchingSingle = true;
    notifyListeners();
    try {
      selectedQuestion = await _questionRepository.getQuestionById(questionId);
      debugPrint("Fetched question $questionId: $selectedQuestion");
    } catch (e) {
      print("Error fetching question by ID: $e");
    } finally {
      isFetchingSingle = false;
      notifyListeners();
    }
  }


  // Future<bool> handleVote(int questionId, int userId, String voteType) async {
  //   try {
  //     await _questionRepository.voteQuestion(questionId, userId, voteType);
  //     return true;
  //   } catch (e) {
  //     debugPrint("Lỗi khi vote: $e");
  //     return false;
  //   }
  // }


}
