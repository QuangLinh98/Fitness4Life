import 'package:flutter/material.dart';
import '../service/ChatService.dart';

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({Key? key}) : super(key: key);

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  bool isChatOpen = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // Cập nhật kiểu dữ liệu

  void _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
    });

    _messageController.clear();

    // Gọi API Gemini thay vì giả lập tin nhắn bot
    String botResponse = await ChatService.sendMessage(userMessage);

    setState(() {
      _messages.add({"sender": "bot", "text": botResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isChatOpen)
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Chatbot",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              isChatOpen = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Danh sách tin nhắn
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg["sender"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: msg["sender"] == "user" ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(msg["text"]!, style: TextStyle(color: Colors.black)),
                          ),
                        );
                      },
                    ),
                  ),

                  // Ô nhập tin nhắn
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Nhập tin nhắn...",
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _sendMessage(), // Gửi tin nhắn khi nhấn Enter
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.purple),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Nút mở chat
          FloatingActionButton(
            onPressed: () {
              setState(() {
                isChatOpen = !isChatOpen;
              });
            },
            backgroundColor: Colors.purple,
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ],
      ),
    );
  }
}