import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/service/UserInfoProvider.dart';
import '../../../data/models/promotion/Point.dart';
import '../../../service/PromotionService.dart';
import '../RewardProgramPage.dart';

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
        preferredSize: Size.fromHeight(100),
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
                          "Exclusive Deals & Rewards",
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
                Tab(text: "Introduction"),
                Tab(text: "Your Coupons"),
                Tab(text: "Redeem Points"),
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
                      "Your Points: ${userInfo.userPoint}",
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
                _buildIntroductionTab("Introduction"),
                _buildYourCouponsTab(),
                _buildRedeemPointsTab("Redeem Points"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab(String tabName) {
    if (tabName == "Introduction") {
      return RewardProgramPage();
    } else {
      return Center(
        child: Text(
          "Danh mục $tabName chưa được cập nhật!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget _buildYourCouponsTab() {
    final promotionService = Provider.of<PromotionService>(context);

    if (promotionService.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final availablePromotions = promotionService.promotions;

    if (availablePromotions.isEmpty) {
      return Center(
        child: Text(
          "You have no available coupons at the moment.",
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
                  "Code: ${promo.promotionCode}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Discount Amount: ${promo.promotionAmount}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Valid From: ${promo.startDate}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "Expires On: ${promo.endDate}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRedeemPointsTab(tabName) {
    if (tabName == "Redeem Points") {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Redeem Your Points",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Convert your points into discount coupons and save on your next purchase.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement redeem logic
              },
              child: Text("Redeem Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB00020),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          "Danh mục $tabName chưa được cập nhật!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

  }
}
