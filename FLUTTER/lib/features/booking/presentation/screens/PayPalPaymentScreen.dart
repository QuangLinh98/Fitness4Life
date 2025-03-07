import 'package:fitness4life/features/booking/service/PaypalService.dart';
import 'package:fitness4life/features/booking/service/WorkoutPackageService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../token/token_manager.dart';
import '../../../smart_deal/service/PromotionService.dart';
import '../../data/WorkoutPackage.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final int userId;
  final int packageId;
  final PackageName packageName; // thêm

  const PayPalPaymentScreen({super.key, required this.userId, required this.packageId, required this.packageName});

  @override
  _PayPalPaymentScreenState createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  late PaypalService _paypalService;
  double? totalAmount; // ✅ Giá trị gói tập từ DB
  double? discountedAmount;  //Giá mã giảm giá
  String? discountCode;
  bool _isLoading = false;
  String? _selectedDiscountCode;
  Map<String, double>? _discountCodes;
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paypalService = Provider.of<PaypalService>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _fetchPackageDetails();
      _fetchUserPromotions();
    });

  }

  Future<void> _fetchUserPromotions() async {
    final promotionService = Provider.of<PromotionService>(context, listen: false);
    await promotionService.getPromotionOfUserById(widget.userId);
  }
  /// **📌 Lấy giá trị gói tập từ database**
  Future<void> _fetchPackageDetails() async {
    setState(() => _isLoading = true);
    try {

      final packageDetails = await Provider.of<WorkoutPackageService>(context, listen: false)
          .fetchPackageById(widget.packageId);
      setState(() {
        totalAmount = packageDetails?.price;
        discountedAmount = totalAmount;   //Giá mặc định chưa giảm
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

  /// **📌 Áp dụng mã giảm giá**
  Future<void> _applyDiscount() async {
    if (_discountCodes == null || totalAmount == null) {
      _showSnackBar("❌ Please select a valid promotion!");
      return;
    }

    String enteredCode = _discountController.text;
    double discount = _discountCodes![enteredCode] ?? 0;
    print("✅ Mã giảm giá: $enteredCode");
    discountCode = enteredCode;
    print("✅ Giá trị giảm: $discount");
    final promotionService = Provider.of<PromotionService>(context, listen: false);

    bool isValid = await promotionService.findCodeOfUser(enteredCode, widget.userId);
    print('isValid: $isValid');
    if (isValid) {
      setState(() {
        discountedAmount = totalAmount! - discount;
      });
      _showSnackBar("✅ Discount applied: -${discount}\$");
    } else {
      _showSnackBar("❌ Invalid or unauthorized coupon code!");
    }

  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      String? approvalUrl = await _paypalService.createPayment(discountedAmount ?? totalAmount!,widget.userId, widget.packageId,discountCode);
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
    final promotionService = Provider.of<PromotionService>(context);
    final availablePromotions = promotionService.promotionOfUsers
        .where((promo) => totalAmount != null &&
        totalAmount! >= promo.minValue &&
        (promo.packageName == null ||
            promo.packageName.isEmpty ||
            promo.packageName.any((name) =>
            name.toLowerCase() == widget.packageName.name.toLowerCase())))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Payment")),
        backgroundColor: const Color(0xFFB00020),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/paypal-logo.webp', height: 200, width: 300),
            const SizedBox(height: 20),

            // **💰 Hiển thị giá ban đầu**
            if (totalAmount != null)
              Text("Original Price: \$${totalAmount!.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Chọn khuyến mãi",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _applyDiscount,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),

              value: _selectedDiscountCode,
              items: availablePromotions
                  .where((promo) => promo.promotionAmount > 0) // Lọc chỉ các promotionAmount > 0
                  .map((promo) {
                return DropdownMenuItem<String>(
                  value: promo.code,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${promo.code} - ${promo.promotionAmount}\$",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "price reduction: ${promo.discountValue}\$",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "minimum price: ${promo.minValue}\$",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "📅 ${promo.startDate} ➝ ${promo.endDate}",
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? selectedCode) {
                if (selectedCode != null) {
                  final selectedPromo = availablePromotions.firstWhere(
                        (promo) => promo.code == selectedCode,
                  );
                  setState(() {
                    _selectedDiscountCode = selectedCode;
                    _discountController.text = selectedCode;
                    _discountCodes = {selectedCode: selectedPromo?.discountValue ?? 0};
                  });
                }
              },
              selectedItemBuilder: (BuildContext context) {
                return availablePromotions.map((promo) {
                  return Text(
                    promo.code, // Chỉ hiển thị mã giảm giá khi đã chọn
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  );
                }).toList();
              },
            ),

            const SizedBox(height: 10),
            // **💲 Hiển thị giá sau giảm (nếu có)**
            if (discountedAmount != null && discountedAmount != totalAmount)
              Text("Discounted Price: \$${discountedAmount!.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),

            // **🛒 Nút thanh toán PayPal**
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _startPayPalPayment,
              icon: const Icon(Icons.payment),
              label: Text("Pay with PayPal (\$${discountedAmount?.toStringAsFixed(2) ?? "..."})"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
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