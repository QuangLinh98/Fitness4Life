import 'package:flutter/material.dart';
import 'package:fitness4life/features/smart_deal/service/BlogService.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../config/constants.dart';
import 'BlogDetail.dart';

class GetAllBlog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Chiều cao AppBar
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFB00020), // Đổi màu nền AppBar
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15), // Bo góc phía dưới
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Blog",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // Để căn giữa tiêu đề
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: blogService.blogs.length,
          itemBuilder: (context, index) {
            final blog = blogService.blogs[index];
            final imageUrls = blog.thumbnailUrl
                .map((img) => getFullImageUrl(img.imageUrl))
                .toList();

            final displayImages =
            imageUrls.length > 4 ? imageUrls.sublist(0, 4) : imageUrls;

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
                        if (displayImages.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
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
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey),
                                ),
                              );
                            },
                          ),

                        // Tiêu đề của bài viết
                        const SizedBox(height: 8),
                        Text(
                          blog.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "${blog.content.length > 300 ? blog.content.substring(0, 300) + '...' : blog.content}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "${blog.createdAt.toLocal()}".split(' ')[0],
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
            );
          },
        ),
      ),
    );
  }
}