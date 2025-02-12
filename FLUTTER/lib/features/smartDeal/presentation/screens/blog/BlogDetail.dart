import 'package:fitness4life/features/smartDeal/service/BlogService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constants.dart';
import '../CommentPage.dart';

class Blogdetail extends StatefulWidget {
  final int blogId;
  const Blogdetail({super.key, required this.blogId});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Blogdetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final blogService = Provider.of<BlogService>(context, listen: false);
      blogService.fetchBlogById(widget.blogId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final blogService = Provider.of<BlogService>(context);
    final blog = blogService.blog;

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
                      "Explore Posts",
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
      body: blogService.isFetchingSingle
          ? const Center(child: CircularProgressIndicator())
          : blog != null
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề câu hỏi
              Text(
                blog.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              // Tên tác giả và thời gian đăng câu hỏi (cùng hàng)
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("By ${blog.authorName}", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const Spacer(),
                  const Icon(Icons.date_range, size: 18, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(DateFormat.yMMMd().format(blog.createdAt), style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
              Chip(
                label: Text(
                  blog.category, // Nếu status là một chuỗi
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              // Hình ảnh câu hỏi (nếu có)
              if (blog.thumbnailUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: getFullImageUrl(blog.thumbnailUrl.first.imageUrl),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              // Nội dung câu hỏi
              Text(
                blog.content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              // Thông tin bổ sung
              Divider(),
              const SizedBox(height: 20),
              // 🛑 🛑 🛑hiển thị danh sách comment 🛑 🛑 🛑
              const Divider(),
              const SizedBox(height: 10),
              // CommentPage(questionId: widget.questionId),
            ],
          ),
        ),
      )
          : const Center(child: Text("No data available")),
    );
  }
}


