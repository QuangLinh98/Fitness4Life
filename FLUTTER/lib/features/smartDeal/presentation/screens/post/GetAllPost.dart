import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smartDeal/service/QuestionService.dart';
import '../../../../../config/constants.dart';
import '../../../../user/service/UserInfoProvider.dart';
import '../CreateQuestionScreen.dart';
import 'Posts.dart';

class GetAllPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionService = Provider.of<QuestionService>(context);

    final sortedQuestions = List.from(questionService.questions)
        .where((q) => q.status == "APPROVED")
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Chiều cao AppBar
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB00020),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15), // Bo góc phía dưới
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Back
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Tiêu đề căn giữa
                  Expanded(
                    child: Center(
                      child: Text(
                        "Community Posts",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Nút dấu cộng
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white), // Biểu tượng dấu cộng
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateQuestionScreen()),
                      ); // Điều hướng sang trang tạo bài viết
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: sortedQuestions.length,
          itemBuilder: (context, index) {
            final question = sortedQuestions[index];
            final imageUrls = question.questionImages
                .map((img) => getFullImageUrl(img.imageUrl))
                .toList();

            final displayImages = imageUrls.length > 4 ? imageUrls.sublist(0, 4) : imageUrls;

            return GestureDetector(
              onTap: () {
                // Chuyển đến trang chi tiết bài viết khi nhấn vào Card
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Posts(questionId: question.id),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  question.author[0].toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.author,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    "${question.createdAt.toLocal()}".split(' ')[0],
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                            onPressed: () {
                              // Xử lý khi nhấn vào nút more
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bọc tiêu đề với GestureDetector để bắt sự kiện nhấn
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Posts(questionId: question.id),
                            ),
                          );
                        },
                        child: Text(
                          question.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Đổi màu để thấy rõ là clickable
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (displayImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: displayImages.length > 1 ? 2 : 1,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                          ),
                          itemCount: displayImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Posts(questionId: question.id),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: displayImages[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          "${question.content.length > 300 ? question.content.substring(0, 300) + '...' : question.content}",
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up, color: Colors.blueAccent, size: 24),
                                onPressed: () {
                                  // Xử lý khi nhấn like
                                },
                              ),
                              Text("${question.upvote}", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.thumb_down, color: Colors.redAccent, size: 24),
                                onPressed: () {
                                  // Xử lý khi nhấn dislike
                                },
                              ),
                              Text("${question.downVote}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.remove_red_eye, color: Colors.grey, size: 18),
                              const SizedBox(width: 5),
                              Text("${question.viewCount}", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
