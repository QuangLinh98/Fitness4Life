import 'package:fitness4life/api/SmartDeal_Repository/BlogRepository.dart';
import 'package:fitness4life/features/smart_deal/data/models/blog/Blog.dart';
import 'package:flutter/cupertino.dart';

class BlogService extends ChangeNotifier {
  final BlogRepository _blogRepository;

  List<Blog> blogs = [];
  bool isLoading = false;

  Blog? blog;
  bool isFetchingSingle = false;

  BlogService(this._blogRepository);

  // Get all blog
  Future<void> fetchAllBlog() async {
    isLoading = true;
    notifyListeners();
    try {
      blogs = await _blogRepository.getAllBlog();
      debugPrint("Fetched blogs: $blogs");
    } catch (e) {
      print("Error fetching blogs: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBlogById(int blogId) async {
    isFetchingSingle = true;
    notifyListeners();
    try {
      blog = await _blogRepository.getBlogById(blogId);
      debugPrint("Fetched blog $blogId: $blog");
    } catch (e) {
      print("Error fetching blog by ID: $e");
    } finally {
      isFetchingSingle = false;
      notifyListeners();
    }
  }
}