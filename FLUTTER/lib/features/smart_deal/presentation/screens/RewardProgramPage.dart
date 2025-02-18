import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/LanguageProvider.dart'; // Đảm bảo import đúng file của bạn

class RewardProgramPage extends StatefulWidget {
  const RewardProgramPage({super.key});

  @override
  _RewardProgramPageState createState() => _RewardProgramPageState();
}

class _RewardProgramPageState extends State<RewardProgramPage> {
  @override
  Widget build(BuildContext context) {
    // ✅ Lấy trạng thái ngôn ngữ một lần duy nhất
    final isVietnamese = Provider.of<LanguageProvider>(context).isVietnamese;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVietnamese
                    ? "Tham gia các thử thách tập luyện để tích điểm và đổi quà!"
                    : "Join workout challenges to earn points and redeem rewards!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CachedNetworkImage(
                imageUrl: "https://images.pexels.com/photos/4168092/pexels-photo-4168092.jpeg",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                isVietnamese ? "Cách thức tham gia:" : "How to join:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildStep(context, isVietnamese
                  ? "1. Hoàn thành các bài tập hàng ngày để nhận điểm."
                  : "1. Complete daily workouts to earn points."),
              _buildStep(context, isVietnamese
                  ? "2. Tham gia thử thách hàng tuần để nhận phần thưởng lớn."
                  : "2. Join weekly challenges to earn big rewards."),
              _buildStep(context, isVietnamese
                  ? "3. Sử dụng điểm để đổi mã giảm giá, khóa tập thử và quà tặng đặc biệt."
                  : "3. Redeem points for discount vouchers, trial classes, and special gifts."),
              const SizedBox(height: 20),
              Text(
                isVietnamese ? "Các phần thưởng hấp dẫn:" : "Exciting rewards:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildRewardItem(context,
                  isVietnamese ? "Giảm 20% gói tập Gym 3 tháng" : "20% off 3-month Gym package",
                  isVietnamese ? "500 điểm" : "500 points",
                  "https://images.pexels.com/photos/3253501/pexels-photo-3253501.jpeg"),
              _buildRewardItem(context,
                  isVietnamese ? "1 tuần tập thử Yoga miễn phí" : "1 week free Yoga trial",
                  isVietnamese ? "300 điểm" : "300 points",
                  "https://images.pexels.com/photos/3253501/pexels-photo-3253501.jpeg"),
              _buildRewardItem(context,
                  isVietnamese ? "Voucher mua sắm đồ thể thao" : "Sports shopping voucher",
                  isVietnamese ? "700 điểm" : "700 points",
                  "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg"),
              _buildRewardItem(context,
                  isVietnamese ? "Khóa học Kickboxing miễn phí" : "Free Kickboxing course",
                  isVietnamese ? "600 điểm" : "600 points",
                  "https://images.pexels.com/photos/4761793/pexels-photo-4761793.jpeg"),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
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
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String stepText) {
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

  Widget _buildRewardItem(BuildContext context, String title, String points, String imageUrl) {
    final isVietnamese = Provider.of<LanguageProvider>(context).isVietnamese;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  isVietnamese ? "Yêu cầu: $points" : "Required: $points",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
