import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness4life/features/smart_deal/service/BlogService.dart';
import '../../../../../config/constants.dart';
import 'GetAllBlog.dart';
import 'BlogDetail.dart';

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
      Provider.of<BlogService>(context, listen: false).fetchAllBlog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Blog",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        ),
        const SizedBox(height: 10),
        blogService.isLoading
            ? const Center(child: CircularProgressIndicator())
            : blogService.blogs.isNotEmpty
            ? CarouselSlider.builder(
          options: CarouselOptions(
            height: 230,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 1,
            clipBehavior: Clip.none,
          ),
          itemCount: blogService.blogs.length > 10 ? 10 : blogService.blogs.length,
          itemBuilder: (context, index, realIndex) {
            final blog = blogService.blogs[index];
            String imageUrl = "https://via.placeholder.com/300";
            if (blog.thumbnailUrl.isNotEmpty) {
              String url = blog.thumbnailUrl.first.imageUrl;
              if (url.startsWith("http://") || url.startsWith("https://")) {
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
                            width: screenWidth * 0.8,
                            child: Text(
                              blog.title.length > 50
                                  ? "${blog.title.substring(0, 50)}..."
                                  : blog.title,
                              style: TextStyle(
                                fontSize: blog.title.length > 50 ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
            : const Center(child: Text("Không có bài blog nào")),
      ],
    );
  }
}