import 'package:fitness4life/features/smartDeal/data/models/blog/Blog.dart';

import '../api_gateway.dart';

class BlogRepository{
  final ApiGateWayService _apiGateWayService;

  BlogRepository(this._apiGateWayService);

  Future<List<Blog>> getAllBlog() async {
    try {
      final response = await _apiGateWayService.getData('/deal/blogs');

      if (response.data != null && response.data['data'] is List) {
        List<dynamic> dataList = response.data['data'];

        List<Blog?> blogs = dataList.map((json) {
          try {
            Blog blog = Blog.fromJson(json);
            return blog;
          } catch (e) {
            print("❌ Lỗi chuyển đổi blog: $e");
            return null;
          }
        }).where((item) => item != null).toList();
        return blogs.cast<Blog>();
      } else {
        throw Exception("Invalid response structure or 'data' is not a List.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách blog: $e");
      throw Exception("Failed to fetch blog. Please try again later.");
    }
  }

  Future<Blog?> getBlogById(int blogId) async {
    try {
      final response = await _apiGateWayService.getData('/deal/blogs/$blogId');

      if (response.data != null && response.data['data'] != null) {
        try {
          Blog blog = Blog.fromJson(response.data['data']);
          return blog;
        } catch (e) {
          print("❌ Lỗi chuyển đổi blog one: $e");
          return null;
        }
      } else {
        throw Exception("Invalid response structure or no data found.");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy blog $blogId: $e");
      throw Exception("Failed to fetch blog. Please try again later.");
    }
  }
}