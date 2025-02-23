import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/LanguageProvider.dart';
import '../../../../user/service/UserInfoProvider.dart';
import '../../../data/models/promotion/Point.dart';
import '../../../service/PromotionService.dart';
import 'RewardDetailPage.dart';

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
    void _navigateToDetailPage(String promotionId, String title, String points, String imageUrl, int point) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RewardDetailPage(
            promotionId: promotionId,
            title: title,
            points: points,
            imageUrl: imageUrl,
            point: point,
          ),
        ),
      );
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
                _buildIntroductionTab("Introduction", _tabController),
                _buildYourCouponsTab(),
                _buildRedeemPointsTab("Redeem Points"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionTab(String tabName, TabController tabController) {
    if (tabName == "Introduction") {
      final isVietnamese = Provider.of<LanguageProvider>(context).isVietnamese;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề chính
            Text(
              isVietnamese
                  ? "Tham gia chương trình tích điểm - Nhận thưởng hấp dẫn!"
                  : "Join the Points Program - Earn Exciting Rewards!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isVietnamese
                  ? "Bạn có thể tích điểm bằng cách hoàn thành các thử thách tập luyện hàng ngày và hàng tuần. Điểm tích lũy có thể đổi thành mã giảm giá, quà tặng hoặc các buổi tập miễn phí!"
                  : "Earn points by completing daily and weekly workout challenges. Redeem your points for discount vouchers, gifts, and free training sessions!",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Hình ảnh minh họa
            CachedNetworkImage(
              imageUrl: "https://images.pexels.com/photos/4168092/pexels-photo-4168092.jpeg",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            // Cách thức tham gia
            Text(
              isVietnamese ? "Cách thức tham gia:" : "How to Join:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStep(isVietnamese
                ? "✅ Hoàn thành các bài tập hàng ngày để nhận điểm."
                : "✅ Complete daily workouts to earn points."),
            _buildStep(isVietnamese
                ? "🏆 Tham gia thử thách hàng tuần để nhận phần thưởng lớn."
                : "🏆 Join weekly challenges for bigger rewards."),
            _buildStep(isVietnamese
                ? "🎁 Sử dụng điểm để đổi mã giảm giá, khóa tập thử và quà tặng đặc biệt."
                : "🎁 Redeem points for discount vouchers, trial classes, and special gifts."),
            const SizedBox(height: 20),

            // Các loại thử thách
            Text(
              isVietnamese ? "Các loại thử thách:" : "Types of Challenges:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStep(isVietnamese
                ? "🔥 Thử thách 7 ngày: Hoàn thành ít nhất 30 phút tập luyện mỗi ngày trong 7 ngày liên tiếp."
                : "🔥 7-Day Challenge: Complete at least 30 minutes of workout daily for 7 consecutive days."),
            _buildStep(isVietnamese
                ? "💪 Thử thách sức mạnh: Nâng tổng tạ 500kg trong 1 tuần."
                : "💪 Strength Challenge: Lift a total of 500kg in a week."),
            _buildStep(isVietnamese
                ? "🏃‍♂️ Thử thách Cardio: Chạy bộ tổng cộng 15km trong tuần."
                : "🏃‍♂️ Cardio Challenge: Run a total of 15km in a week."),
            const SizedBox(height: 20),

            // Danh sách phần thưởng hấp dẫn
            Text(
              isVietnamese ? "Các phần thưởng hấp dẫn:" : "Exciting Rewards:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildRewardList(isVietnamese),

            const SizedBox(height: 20),

            // Câu hỏi thường gặp (FAQ)
            Text(
              isVietnamese ? "Câu hỏi thường gặp:" : "Frequently Asked Questions:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStep(isVietnamese
                ? "❓ Tôi có thể đổi điểm sang tiền mặt không? → Không, điểm chỉ dùng để đổi quà."
                : "❓ Can I convert points into cash? → No, points can only be redeemed for rewards."),
            _buildStep(isVietnamese
                ? "❓ Điểm có hết hạn không? → Điểm sẽ hết hạn sau 6 tháng nếu không sử dụng."
                : "❓ Do points expire? → Yes, points expire after 6 months if not used."),
            _buildStep(isVietnamese
                ? "❓ Tôi có thể tích điểm bằng cách nào khác? → Bạn có thể giới thiệu bạn bè để nhận thêm điểm thưởng!"
                : "❓ How else can I earn points? → You can refer friends to earn bonus points!"),
            const SizedBox(height: 20),

            // Nút kêu gọi hành động
            Center(
              child: ElevatedButton(
                onPressed: () {
                  tabController.index = 2;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  isVietnamese ? "Bắt đầu tích điểm ngay" : "Start earning points now",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          "Danh mục $tabName chưa được cập nhật!",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget _buildStep(String stepText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(stepText, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
    List<Map<String, dynamic>> rewards = [
      {
        "promotionId": "promo_001",
        "title_vi": "Giảm 20% gói tập Gym 3 tháng",
        "title_en": "20% off 3-month Gym package",
        "points": "500 điểm",
        "point": 500, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg",
      },
      {
        "promotionId": "promo_002",
        "title_vi": "1 tuần tập thử Yoga miễn phí",
        "title_en": "1 week free Yoga trial",
        "points": "1000 điểm",
        "point": 1000, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/4167544/pexels-photo-4167544.jpeg",
      },
      {
        "promotionId": "promo_001",
        "title_vi": "Giảm 20% gói tập Gym 3 tháng",
        "title_en": "20% off 3-month Gym package",
        "points": "1500 điểm",
        "point": 1500, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/2261477/pexels-photo-2261477.jpeg",
      },
      {
        "promotionId": "promo_002",
        "title_vi": "1 tuần tập thử Yoga miễn phí",
        "title_en": "1 week free Yoga trial",
        "points": "2000 điểm",
        "point": 2000, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/3253501/pexels-photo-3253501.jpeg",
      },
      {
        "promotionId": "promo_001",
        "title_vi": "Giảm 20% gói tập Gym 3 tháng",
        "title_en": "20% off 3-month Gym package",
        "points": "2500 điểm",
        "point": 2500, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/1954524/pexels-photo-1954524.jpeg",
      },
      {
        "promotionId": "promo_002",
        "title_vi": "1 tuần tập thử Yoga miễn phí",
        "title_en": "1 week free Yoga trial",
        "points": "3000 điểm",
        "point": 3000, // Dữ liệu ẩn
        "imageUrl": "https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg",
      },
    ];

    Widget _buildRewardList(bool isVietnamese) {
      return Column(
        children: rewards.map((reward) {
          return _buildRewardItem(
            reward["promotionId"], // Truyền promotionId
            isVietnamese ? reward["title_vi"] : reward["title_en"],
            reward["points"],
            reward["imageUrl"],
            reward["point"], // Truyền point
          );
        }).toList(),
      );
    }


    Widget _buildRewardItem(String promotionId, String title, String points, String imageUrl, int point) {
      return GestureDetector(
        onTap: () {
          _navigateToDetailPage(promotionId, title, points, imageUrl, point);
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(points, style: const TextStyle(fontSize: 14, color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


  void _showRedeemDialog(String rewardName, int pointsRequired) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận đổi quà"),
          content: Text("Bạn có chắc chắn muốn đổi \"$rewardName\" với $pointsRequired điểm không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                // Gửi yêu cầu đổi quà tại đây
                _redeemReward(rewardName, pointsRequired);
                Navigator.pop(context);
              },
              child: Text("Đổi quà"),
            ),
          ],
        );
      },
    );
  }
  void _redeemReward(String rewardName, int pointsRequired) {
    // Giả lập xử lý đổi quà
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã đổi thành công $rewardName!")),
    );

    // TODO: Gửi request lên server để trừ điểm và xác nhận đổi quà
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
    int currentPoint = userInfo.userPoint;
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
                      // _buildInfoRow("Promo Code", promo.code, color: Colors.purple),
                      // _buildInfoRow("Promo Id", promo.id, color: Colors.purple),
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
