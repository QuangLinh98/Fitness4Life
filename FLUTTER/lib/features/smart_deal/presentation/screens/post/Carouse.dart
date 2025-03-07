import 'package:carousel_slider/carousel_slider.dart';
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
      Provider.of<QuestionService>(context, listen: false).fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionService = Provider.of<QuestionService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final approvedQuestions = questionService.questions
        .where((q) => q.status == "APPROVED")
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Forum Questions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetAllPost()),
                ),
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        questionService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : approvedQuestions.isNotEmpty
            ? CarouselSlider.builder(
          options: CarouselOptions(
            height: 230,
            // enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 1,
            clipBehavior: Clip.none,
          ),
          itemCount: approvedQuestions.length > 10 ? 10 : approvedQuestions.length,
          itemBuilder: (context, index, realIndex) {
            final question = approvedQuestions[index];
            String imageUrl = "https://via.placeholder.com/300";
            if (question.questionImages.isNotEmpty) {
              String url = question.questionImages.first.imageUrl;
              if (url.startsWith("http://") || url.startsWith("https://")) {
                imageUrl = getFullImageUrl(url);
              }
            }
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
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          height: 130,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8, // Giới hạn chiều rộng
                            child: Text(
                              question.title.length > 50
                                  ? "${question.title.substring(0, 50)}..."
                                  : question.title,
                              style: TextStyle(
                                fontSize: question.title.length > 50 ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible( // Tránh lỗi tràn khi thu nhỏ
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 16, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${question.viewCount} views",
                                      style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blueGrey),
                            ],
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              ),
            );
          },
        )
            : const Center(child: Text("No approved questions available", style: TextStyle(color: Colors.grey))),
      ],
    );
  }
}
