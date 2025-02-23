import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RewardDetailPage extends StatefulWidget {
  final String title;
  final String points;
  final String imageUrl;
  final String promotionId;
  final int point;

  const RewardDetailPage({
    Key? key,
    required this.title,
    required this.points,
    required this.imageUrl,
    required this.promotionId,
    required this.point,
  }) : super(key: key);

  @override
  _RewardDetailPageState createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends State<RewardDetailPage> {
  bool isRedeemed = false;

  void _redeemReward() {
    setState(() {
      isRedeemed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bạn đã đổi thành công ${widget.title}!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Điểm yêu cầu: ${widget.points}", style: const TextStyle(fontSize: 18, color: Colors.redAccent)),
            const SizedBox(height: 10),
            Text("Điểm của bạn: ${widget.point}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 10),
            Text("Mã khuyến mãi: ${widget.promotionId}", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            const Text(
              "Chi tiết phần thưởng:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bạn có thể sử dụng điểm tích lũy để đổi phần thưởng này và tận hưởng ưu đãi đặc biệt!",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: isRedeemed ? null : _redeemReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  isRedeemed ? "Đã đổi quà" : "Đổi quà ngay",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
