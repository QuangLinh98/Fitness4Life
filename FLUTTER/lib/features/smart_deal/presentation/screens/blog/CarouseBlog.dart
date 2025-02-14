import 'package:fitness4life/features/smart_deal/presentation/screens/blog/BlogDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smart_deal/service/BlogService.dart';

import '../../../../../config/constants.dart';
import 'GetAllBlog.dart';

class CarouseBlog extends StatefulWidget {
  const CarouseBlog({super.key});

  @override
  _CarouseBlogState createState() => _CarouseBlogState();
}

class _CarouseBlogState extends State<CarouseBlog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final blogService = Provider.of<BlogService>(context, listen: false);
      blogService.fetchAllBlog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Blog",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetAllBlog()),
                );
              },
              child: const Text("View All"),
            ),
          ],
        ),

        const SizedBox(height: 10),
        blogService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : blogService.blogs.isNotEmpty
            ? SizedBox(
          height: 180,
          width: screenWidth,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blogService.blogs.length > 10 ? 10 : blogService.blogs.length,
            itemBuilder: (context, index) {
              final blog = blogService.blogs[index];

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
                              print("❌ Lỗi tải ảnh: $error - URL: $url");
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
                                blog.title.length > 25
                                    ? "${blog.title.substring(0, 25)}..."
                                    : blog.title,
                                style: TextStyle(
                                  fontSize: blog.title.length > 25 ? 14 : 16,
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
