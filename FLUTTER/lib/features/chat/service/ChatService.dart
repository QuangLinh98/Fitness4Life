import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {

  static const String apiKey = "AIzaSyD5ReNviWXwMzk29ZzHhKVU0cXQm4j61Sk";
  static const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  // Từ điển phản hồi dựa trên từ khóa
  static const predefinedResponses = {
    "vi": [
      {
        "keywords": ["đăng ký tài khoản", "cách đăng ký tài khoản", "tạo tài khoản", "mở tài khoản"],
        "response": "Bạn có thể đăng ký tài khoản tại <a href='/register'>Đăng ký tài khoản</a>. Nếu gặp vấn đề, vui lòng liên hệ <a href='/support'>Hỗ trợ</a>."
      },
      {
        "keywords": ["giới thiệu trang web", "trang web này là gì", "FITNESS4ONLINE là gì"],
        "response": "FITNESS4ONLINE là nền tảng tập luyện thể thao giúp bạn xây dựng lối sống khỏe mạnh. Xem thêm tại <a href='/about'>Giới thiệu</a>."
      },
      {
        "keywords": ["mua gói tập", "đăng ký tập gym", "gói thành viên", "membership"],
        "response": "Bạn có thể xem các gói tập tại <a href='/membership'>Membership</a> và chọn gói phù hợp."
      },
      {
        "keywords": ["hỗ trợ kỹ thuật", "tài khoản bị lỗi", "không đăng nhập được"],
        "response": "Nếu bạn gặp sự cố kỹ thuật, vui lòng truy cập <a href='/support'>Hỗ trợ</a> hoặc liên hệ admin."
      },
      {
        "keywords": ["hoàn tiền", "chính sách hoàn tiền", "hủy gói tập"],
        "response": "Bạn có thể yêu cầu hoàn tiền trong vòng 7 ngày kể từ khi đăng ký. Chi tiết tại <a href='/refund-policy'>Chính sách hoàn tiền</a>."
      }
    ],
    "en": [
      {
        "keywords": ["register an account", "how to register", "create account", "sign up"],
        "response": "You can register at <a href='/register'>Register</a>. If you have any issues, please visit <a href='/support'>Support</a>."
      },
      {
        "keywords": ["about this website", "what is this website", "what is FITNESS4ONLINE"],
        "response": "FITNESS4ONLINE is a platform that provides fitness training services. Learn more at <a href='/about'>About Us</a>."
      },
      {
        "keywords": ["buy training package", "register for gym", "membership options"],
        "response": "You can explore different membership plans at <a href='/membership'>Membership</a> and choose the one that suits you best."
      },
      {
        "keywords": ["technical support", "account issue", "login problem"],
        "response": "If you encounter any technical issues, please visit <a href='/support'>Support</a> or contact our administrator."
      },
      {
        "keywords": ["refund policy", "how to get a refund", "cancel membership"],
        "response": "You can request a refund within 7 days of purchase. Read our <a href='/refund-policy'>Refund Policy</a> for more details."
      }
    ]
  };

// Hàm xử lý từ khóa và phản hồi phù hợp
  static String? getPredefinedResponse(String message) {
    bool isEnglish = RegExp(r'^[a-zA-Z0-9\s.,!?]+$').hasMatch(message);
    String language = isEnglish ? "en" : "vi";

    // Kiểm tra xem danh sách phản hồi có tồn tại không
    List<Map<String, dynamic>>? responses = predefinedResponses[language];

    if (responses == null) return null; // Tránh lỗi null

    for (var entry in responses) {
      List<dynamic>? keywords = entry["keywords"];
      if (keywords == null) continue; // Nếu không có từ khóa, bỏ qua entry này

      for (var keyword in keywords) {
        if (message.toLowerCase().contains(keyword.toLowerCase())) {
          var response = entry["response"];

          // Nếu response là một hàm (callback), gọi nó với từ khóa
          if (response is Function) {
            return response(keyword);
          }
          // Nếu response là chuỗi, trả về luôn
          else if (response is String) {
            return response;
          }
        }
      }
    }
    return null; // Không tìm thấy phản hồi phù hợp
  }


  // Hàm gửi tin nhắn đến Gemini API
  static Future<String> sendMessage(String message) async {
    // Kiểm tra xem có phản hồi cài sẵn không
    String? predefinedResponse = getPredefinedResponse(message);
    if (predefinedResponse != null) {
      return predefinedResponse; // Trả về phản hồi cài sẵn nếu tìm thấy từ khóa
    }

    // Nếu không có phản hồi cài sẵn, gọi Gemini AI
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

  // Prompt giúp AI hiểu vai trò của nó
  static String _getPrompt(String message) {
    bool isEnglish = RegExp(r'^[a-zA-Z0-9\s.,!?]+$').hasMatch(message);

    if (isEnglish) {
      return """
      You are a friendly and professional customer support assistant for FITNESS4ONLINE, a fitness training platform.
      - For greetings or casual conversations, respond politely and naturally, then add: 'By the way, is there anything FITNESS4ONLINE can help you with?'
      - For FITNESS4ONLINE-related inquiries (membership, workout plans, pricing, technical support), provide detailed answers.
      - If the question is completely unrelated, respond with: 'I'm here to assist with FITNESS4ONLINE-related questions. Let me know how I can help!'
      User:
    """;
    } else {
      return """
      Bạn là một nhân viên hỗ trợ khách hàng thân thiện và chuyên nghiệp của FITNESS4ONLINE, một nền tảng tập luyện thể thao trực tuyến.
      - Nếu người dùng chào hỏi hoặc trò chuyện bình thường, hãy phản hồi lịch sự và tự nhiên, sau đó thêm: 'FITNESS4ONLINE có thể giúp gì cho bạn không?'
      - Nếu câu hỏi liên quan đến FITNESS4ONLINE (gói tập, kế hoạch tập luyện, giá cả, hỗ trợ kỹ thuật), hãy trả lời chi tiết.
      - Nếu câu hỏi hoàn toàn không liên quan, hãy trả lời: 'Tôi ở đây để hỗ trợ các vấn đề liên quan đến FITNESS4ONLINE. Bạn cần giúp gì không?'
      Người dùng:
    """;
    }
  }

}
