import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../user/service/UserInfoProvider.dart';
import '../../../data/models/promotion/Point.dart';
import '../../../service/PromotionService.dart';

class PromotionScreen extends StatefulWidget {
  @override
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getPoint());
  }

  Future<void> getPoint() async {
    print("fetchUserPoint được gọi");
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    final promotionService = Provider.of<PromotionService>(context, listen: false);

    int? userId = userInfo.userId;
    Point? point = await promotionService.fetchPoint(userId!);
    print("co data được gọi ${point}");

    userInfo.setUserPoint(point!.totalPoints);
  }


  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfoProvider>(context);
    final promotionService = Provider.of<PromotionService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "List Promotion",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Thanh chọn ưu đãi
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Tất cả", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Khả dụng", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Không khả dụng", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hiển thị điểm của user
          promotionService.isLoading
              ? const CircularProgressIndicator()
              : Text(
            "Điểm của bạn: ${userInfo.userPoint}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // Hiển thị thông báo không có ưu đãi
          const Center(
            child: Text(
              "Không có ưu đãi nào vào lúc này",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
