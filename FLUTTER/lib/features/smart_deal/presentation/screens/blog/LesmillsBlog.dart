import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smart_deal/service/BlogService.dart';

import '../../../../../config/constants.dart';
import 'BlogDetail.dart';
import 'GetAllBlog.dart';

class LesmillsBlog extends StatefulWidget {
  const LesmillsBlog({super.key});

  @override
  _LesmillsBlogState createState() => _LesmillsBlogState();
}

class _LesmillsBlogState extends State<LesmillsBlog> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final blogService = Provider.of<BlogService>(context, listen: false);
      blogService.fetchAllBlog();
    });

    _pageController = PageController(viewportFraction: 1);

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage++;
          if (_currentPage >= 3) _currentPage = 0;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lesmills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GetAllBlog()),
              ),
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        blogService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : blogService.blogs.isNotEmpty
            ? SizedBox(
          height: screenHeight * 0.5, // Chiều cao linh hoạt
          width: screenWidth,
          child: PageView.builder(
            controller: _pageController,
            itemCount: (blogService.blogs.length / 4).ceil(),
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 4;
              final endIndex = (startIndex + 4 > blogService.blogs.length)
                  ? blogService.blogs.length
                  : startIndex + 4;
              final pageItems = blogService.blogs.sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Không scroll riêng từng page
                  shrinkWrap: true, // Tránh overflow
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột
                    childAspectRatio: 0.9, // Điều chỉnh tỉ lệ rộng/cao
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    final blog = pageItems[index];
                    // Kiểm tra và lấy URL ảnh hợp lệ
                    String imageUrl = "https://via.placeholder.com/250"; // Ảnh mặc định
                    if (blog.thumbnailUrl.isNotEmpty) {
                      String url = blog.thumbnailUrl.first.imageUrl;
                      if (url.isNotEmpty && (url.startsWith("http://") || url.startsWith("https://"))) {
                        imageUrl = getFullImageUrl(url);
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Blogdetail(blogId: blog.id!),
                          ),
                        );
                      },
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
                                height: screenHeight * 0.15, // Chiều cao ảnh linh hoạt
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    height: screenHeight * 0.15,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
                                    blog.title.length > 25
                                        ? "${blog.title.substring(0, 25)}..."
                                        : blog.title,
                                    style: TextStyle(
                                      fontSize: blog.title.length > 25 ? 12 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        )
            : const Center(child: Text("Không có bài blog nào")),
      ],
    );
  }
}