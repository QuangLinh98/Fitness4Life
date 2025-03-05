import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {

  static const String apiKey = "AIzaSyD5ReNviWXwMzk29ZzHhKVU0cXQm4j61Sk";
  static const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  // Hàm gửi tin nhắn đến Gemini API
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": _getPrompt(message) + message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey("candidates") &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0].containsKey("content") &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"];
        } else {
          return "❌ Lỗi: Không nhận được phản hồi từ Gemini.";
        }
      } else {
        return "❌ Lỗi API (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "❌ Lỗi kết nối: $e";
    }
  }

  static String _getPrompt(String message) {
    bool isEnglish = RegExp(r'^[a-zA-Z0-9\s.,!?]+$').hasMatch(message);
    if (isEnglish) {
      return "You are a customer service assistant. Answer politely and helpfully in English.\nUser: ";
    } else {
      return "Bạn là một trợ lý tư vấn khách hàng. Hãy trả lời lịch sự và hữu ích bằng tiếng Việt.\nNgười dùng: ";
    }
  }

}