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
      fetchPromotionJson();
    });
  }
  Future<void> fetchUserPromotions() async {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    final promotionService = Provider.of<PromotionService>(context, listen: false);
    await promotionService.getPromotionOfUserById(userInfo.userId!);
    Point? point = await promotionService.fetchPoint(userInfo.userId!);
    userInfo.setUserPoint(point!.totalPoints);
  }
  void fetchPromotionJson() {
    final promotionService = Provider.of<PromotionService>(context, listen: false);
    promotionService.fetchPromotionInJson();
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

    final availablePromotions = promotionService.promotionOfUsers;

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
                // Header: Code + View Terms Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Code: ${promo.code}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Terms and Conditions"),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTermsText("Minimum purchase value", promo.minValue.toString()),
                                    _buildTermsText("Discount type", promo.discountValue.toString()),
                                    _buildTermsText("Supported packages", promo.packageName.join(", ")),
                                    _buildTermsText("Promotion description", promo.description),
                                    _buildTermsText("Applicable services", promo.applicableService.join(", ")),
                                    _buildTermsText("Customer type", promo.customerType.join(", ")),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("View Terms", style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Discount Amount
                Text(
                  "Discount Amount: ${promo.promotionAmount}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),

                // Date Information
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
  // Hàm hỗ trợ hiển thị dòng nội dung điều khoản
  Widget _buildTermsText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemPointsTab(String tabName) {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    int? userId = userInfo.userId;
    int currentPoint = userInfo.userPoint!;
    if (tabName == "Redeem Points") {
      return Consumer<PromotionService>(
        builder: (context, promotionService, child) {
          if (promotionService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final promotionList = promotionService.promotionPoints;

          if (promotionList.isEmpty) {
            return Center(
              child: Text(
                "No redeemable promotions available.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: promotionList.length,
            itemBuilder: (context, index) {
              final promo = promotionList[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                color: Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Discount Type
                      Row(
                        children: [
                          Icon(Icons.local_offer, color: Color(0xFFB00020)),
                          SizedBox(width: 10),
                          Text(
                            promo.title,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Description and discount info
                      Text(
                        promo.description,
                        style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
                      ),
                      SizedBox(height: 10),

                      // Discount and Minimum Purchase
                      _buildInfoRow("Discount Value", "${promo.discountValue} đ", color: Color(0xFFB00020)),
                      _buildInfoRow("Min Purchase", "${promo.minValue} đ", color: Colors.green),

                      // Customer Type and Applicable Services
                      _buildInfoRow("Customer Type", promo.customerType.join(", "), color: Colors.blue),
                      _buildInfoRow("Applicable Services", promo.applicableService.join(", "), color: Colors.orange),

                      // Promo Code and Points
                      _buildInfoRow("Promo Code", promo.code, color: Colors.purple),
                      _buildInfoRow("Promo Id", promo.id, color: Colors.purple),
                      _buildInfoRow("Required Points", "${promo.points} points", color: Colors.red),

                      // Redeem Button
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Lấy mã giảm giá từ đối tượng promo
                          final promoId = promo.id;
                          final promoPoint = promo.points;

                          // In mã giảm giá ra console (hoặc có thể làm gì đó khác)
                          print("Promo Code khi click: $promoId");
                          print("Promo point khi click: $promoPoint");
                          print("UserId khi click: $userId");

                          // Kiểm tra nếu điểm hiện tại không đủ để đổi mã
                          if (currentPoint < promoPoint) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Bạn không đủ điểm để đổi mã giảm giá.")),
                            );
                            return; // Không thực hiện tiếp
                          }

                          // Gọi hàm changeCode để thực hiện đổi mã
                          bool success = await promotionService.changeCode(userId!, promoPoint, promoId);

                          // Kiểm tra kết quả và thông báo cho người dùng
                          if (success) {
                            userInfo.setUserPoint(currentPoint - promoPoint);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              fetchUserPromotions();
                            });// Cập nhật điểm sau khi đổi mã
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Đổi mã giảm giá thành công!")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Đã xảy ra lỗi khi đổi mã giảm giá.")),
                            );
                          }
                        },
                        child: Text("Redeem Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB00020), // Red color
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                    ],
                  ),
                ),
              );
            },
          );
        },
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

// Widget hiển thị từng dòng thông tin, có thể thay đổi màu sắc
  Widget _buildInfoRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: color),
          children: [
            TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }


}