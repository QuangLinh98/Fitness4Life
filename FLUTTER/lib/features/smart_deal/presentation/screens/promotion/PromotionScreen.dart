import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/service/UserInfoProvider.dart';
import '../../../data/models/promotion/Point.dart';
import '../../../service/PromotionService.dart';

class PromotionScreen extends StatefulWidget {
  @override
  _PromotionScreenState createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserPromotions();
    });
  }

  Future<void> fetchUserPromotions() async {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    final promotionService = Provider.of<PromotionService>(context, listen: false);
    await promotionService.fetchUserPromotionById(userInfo.userId!);
    Point? point = await promotionService.fetchPoint(userInfo.userId!);
    userInfo.setUserPoint(point!.totalPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100), // Điều chỉnh chiều cao phù hợp
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB00020),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
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
                            "Exclusive Deals List",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              TabBar(
                indicatorColor: const Color(0xFFB00020),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                controller: _tabController,
                tabs: [
                  Tab(text: "Tất cả"),
                  Tab(text: "Khả dụng"),
                  Tab(text: "Không khả dụng"),
                ],
              ),
            ],
          ),
        ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<UserInfoProvider>(
              builder: (context, userInfo, child) {
                return Consumer<PromotionService>(
                  builder: (context, promotionService, child) {
                    return promotionService.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                      "Điểm của bạn: ${userInfo.userPoint}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent("Tất cả"),
                _buildAvailablePromotions(), // Hiển thị danh sách khuyến mãi
                _buildTabContent("Không khả dụng"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePromotions() {
    final promotionService = Provider.of<PromotionService>(context);

    if (promotionService.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final availablePromotions = promotionService.promotions;

    if (availablePromotions.isEmpty) {
      return Center(
        child: Text(
          "Không có ưu đãi nào vào lúc này",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: availablePromotions.length,
      itemBuilder: (context, index) {
        final promo = availablePromotions[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mã: ${promo.promotionCode}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Số lượng: ${promo.promotionAmount}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Bắt đầu: ${promo.startDate}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "Kết thúc: ${promo.endDate}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(String title) {
    return Center(
      child: Text(
        "Dữ liệu tab $title",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
