import 'package:fitness4life/features/booking/service/PaypalService.dart';
import 'package:fitness4life/features/booking/service/WorkoutPackageService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../token/token_manager.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final int userId;
  final int packageId;

  const PayPalPaymentScreen({super.key, required this.userId, required this.packageId});

  @override
  _PayPalPaymentScreenState createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  late PaypalService _paypalService;
  double? totalAmount; // ✅ Giá trị gói tập từ DB
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paypalService = Provider.of<PaypalService>(context, listen: false);
    _fetchPackageDetails();
  }

  /// **📌 Lấy giá trị gói tập từ database**
  Future<void> _fetchPackageDetails() async {
    setState(() => _isLoading = true);
    try {
      final packageDetails = await Provider.of<WorkoutPackageService>(context, listen: false)
          .fetchPackageById(widget.packageId);

      setState(() {
        totalAmount = packageDetails?.price;
      });
    } catch (e) {
      print("❌ Lỗi khi lấy thông tin package: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi khi lấy dữ liệu gói tập!")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// **📌 Bắt đầu thanh toán qua PayPal**
  void _startPayPalPayment() async {
    if (totalAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không thể lấy số tiền thanh toán!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Lấy accessToken từ PayPal
      final accessToken = await TokenManager.getAccessToken();
      if (accessToken == null) {
        print("❌ Lỗi: Không tìm thấy AccessToken!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Lỗi: Vui lòng đăng nhập lại!")),
        );
        return;
      }

      print("🔑 Access Token: $accessToken");

      // ✅ Gửi yêu cầu tạo thanh toán tới PayPal
      String? approvalUrl = await _paypalService.createPayment(totalAmount!,widget.userId, widget.packageId,);
      if (approvalUrl != null) {
        print("✅ Lấy được Approval URL: $approvalUrl");

        // Mở URL thanh toán trên trình duyệt
        _openPayPalUrl(approvalUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không thể lấy URL thanh toán!")),
        );
      }
    } catch (e) {
      print("❌ Lỗi khi tạo thanh toán: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Lỗi khi xử lý thanh toán!")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// **📌 Mở PayPal trên trình duyệt**
  void _openPayPalUrl(String approvalUrl) async {
    if (await canLaunchUrl(Uri.parse(approvalUrl))) {
      bool launched = await launchUrl(
        Uri.parse(approvalUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print("❌ Không thể mở URL: $approvalUrl");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Không thể mở trình duyệt!")),
        );
      }
    } else {
      print("❌ Không thể mở URL: $approvalUrl");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không thể mở trình duyệt!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Payment")),
        backgroundColor: const Color(0xFFB00020),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/paypal-logo.webp', height: 200, width: 300),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _startPayPalPayment,
              child: Text('Pay with PayPal (${totalAmount?.toStringAsFixed(2) ?? "Loading..."}) USD'),
            ),

            const SizedBox(height: 30),

            const Text(
              "Secure Payment Powered by PayPal",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
