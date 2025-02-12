import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smartDeal/service/QuestionService.dart';
import '../../../../../config/constants.dart';
import '../../../../user/service/UserInfoProvider.dart';
import 'Posts.dart';

class YourPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionService = Provider.of<QuestionService>(context);
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);

    String? userName = userInfo.userName;
    int? userId = userInfo.userId;

    // Lọc bài viết theo userId và userName
    final userPosts = questionService.questions
        .where((q) => q.author == userName && q.authorId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text("Bài viết của bạn"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: userPosts.isEmpty
          ? Center(child: Text("Bạn chưa có bài viết nào."))
          : ListView.builder(
        itemCount: userPosts.length,
        itemBuilder: (context, index) {
          final question = userPosts[index];
          final imageUrls = question.questionImages
              .map((img) => getFullImageUrl(img.imageUrl))
              .toList();
          final displayImages = imageUrls.length > 4 ? imageUrls.sublist(0, 4) : imageUrls;

          return GestureDetector(
            onTap: () {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            question.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: null, // Cho phép xuống hàng
                            overflow: TextOverflow.visible, // Hiển thị toàn bộ nội dung
                          ),
                        ),
                        const SizedBox(width: 8), // Khoảng cách giữa tiêu đề và Chip
                        Chip(
                          label: Text(
                            question.status, // Nếu status là một chuỗi
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ],
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
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: displayImages[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
                              onPressed: () {},
                            ),
                            Text("${question.upvote}", style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.thumb_down, color: Colors.redAccent, size: 24),
                              onPressed: () {},
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
    );
  }
}
