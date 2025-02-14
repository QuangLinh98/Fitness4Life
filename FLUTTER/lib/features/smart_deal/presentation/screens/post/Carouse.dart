import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smart_deal/service/QuestionService.dart';

import '../../../../../config/constants.dart';
import 'GetAllPost.dart';
import 'Posts.dart';

class Carouse extends StatefulWidget {
  const Carouse({super.key});

  @override
  _CarouseState createState() => _CarouseState();
}

class _CarouseState extends State<Carouse> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionService = Provider.of<QuestionService>(context, listen: false);
      questionService.fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionService = Provider.of<QuestionService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Lọc chỉ lấy những câu hỏi có status là "APPROVED"
    final approvedQuestions = questionService.questions
        .where((question) => question.status == "APPROVED")
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn hai phần tử về hai bên
          children: [
            const Text(
              "Forum Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetAllPost()),
                );
              },
              child: const Text("View All"),
            ),
          ],
        ),

        const SizedBox(height: 10),
        questionService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : approvedQuestions.isNotEmpty
            ? SizedBox(
          height: 180,
          width: screenWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: approvedQuestions.length > 10 ? 10 : approvedQuestions.length,
            itemBuilder: (context, index) {
              final question = approvedQuestions[index];

              // Kiểm tra và lấy URL ảnh hợp lệ
              String imageUrl = "https://via.placeholder.com/250"; // Ảnh mặc định
              if (question.questionImages.isNotEmpty) {
                String url = question.questionImages.first.imageUrl;
                if (url.isNotEmpty && (url.startsWith("http://") || url.startsWith("https://"))) {
                  imageUrl = getFullImageUrl(url);
                }
              }

              print("🔍 Image URL: $imageUrl"); // Debug log kiểm tra URL ảnh

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Posts(questionId: question.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: screenWidth * 0.7,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              print("❌ Lỗi tải ảnh question: $error - URL: $url");
                              return Container(
                                height: 100,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question.title.length > 25
                                    ? "${question.title.substring(0, 25)}..."
                                    : question.title,
                                style: TextStyle(
                                  fontSize: question.title.length > 25 ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Views: ${question.viewCount}",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
            : const Center(child: Text("No approved questions available")),
      ],
    );
  }
}
