import 'package:fitness4life/features/booking/data/WorkoutPackage.dart';
import 'package:fitness4life/features/booking/presentation/screens/PayPalPaymentScreen.dart';
import 'package:fitness4life/features/booking/service/WorkoutPackageService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WorkoutPackageScreen extends StatefulWidget {
  const WorkoutPackageScreen({super.key});

  @override
  State<WorkoutPackageScreen> createState() => _WorkoutPackageScreenState();
}

class _WorkoutPackageScreenState extends State<WorkoutPackageScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi service để lấy danh sách gói tập
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final packageService =
          Provider.of<WorkoutPackageService>(context, listen: false);
      packageService.fetchWorkoutPackage();
    });
  }



  @override
  Widget build(BuildContext context) {
    final packageService = Provider.of<WorkoutPackageService>(context);
    final packages = packageService.workoutPackages;


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180), // Chiều cao banner
        child: Stack(
          children: [
            // Hình ảnh banner
            Container(
              width: double.infinity,
              height: 400,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/banner1.webp"),
                  // Thay bằng đường dẫn ảnh của bạn
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Lớp phủ mờ để giúp văn bản dễ đọc hơn
            Container(
              width: double.infinity,
              height: 180,
              color:
                  Colors.black.withOpacity(0.3), // Màu tối giúp chữ nổi bật hơn
            ),
            // Văn bản hiển thị trên Banner
            const Positioned(
              top: 100, // Điều chỉnh vị trí chữ
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "HỆ THỐNG PHÒNG TẬP CÔNG KHAI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "MINH BẠCH GIÁ TẬP LUYỆN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Nút quay lại
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      body: packageService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 40),

                // Hiển thị toàn bộ thẻ tập theo GridView
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      itemCount: packages.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 420,
                        // Điều chỉnh độ rộng tối đa của mỗi thẻ
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 80,
                        crossAxisSpacing: 20,
                      ),
                      itemBuilder: (context, index) {
                        return Center(
                          child: WorkoutPackageCard(package: packages[index]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class WorkoutPackageCard extends StatelessWidget {
  final WorkoutPackage package;

  const WorkoutPackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,###").format(package.price);

    // Ánh xạ tên gói tập với hình ảnh tương ứng
    final Map<String, String> packageImages = {
      "CLASSIC": "images/the1.webp",
      "CLASSIC_PLUS": "images/the2.webp",
      "PRESIDENT": "images/the3.webp",
      "ROYAL": "images/the4.webp",
      "SIGNATURE": "images/the5.webp",
    };
    // Lấy hình ảnh phù hợp, nếu không có thì dùng hình mặc định
    final String imagePath = packageImages[
    package.packageName
        .toString()
        .split('.')
        .last
        .toUpperCase()] ??
        "assets/default_card.jpg";


    // 🎨 Layout mặc định cho các gói tập khác
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 1000,
          maxHeight: 1800,
          maxWidth: 280, // Giới hạn chiều rộng tối đa
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiển thị hình ảnh thẻ ngân hàng tương ứng với gói tập
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    package.packageName
                        .toString()
                        .split('.')
                        .last
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    package.packageName
                        .toString()
                        .split('.')
                        .last,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Price: \$${NumberFormat('#,###').format(package.price)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showPackageDetails(context, package, imagePath);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Detail", style: TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **📌 Hàm hiển thị Dialog khi nhấn vào "Detail"**
  void _showPackageDetails(BuildContext context, WorkoutPackage package, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9, // 90% màn hình
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nút đóng dạng "X"
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Tiêu đề
                Text(
                  package.packageName.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Hình ảnh thẻ
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),

                // Giá tiền
                Text(
                  "Package ${package.durationMonth} month: ${NumberFormat("#,###").format(package.price)} USD",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Mô tả
                const Divider(color: Colors.black),
                const SizedBox(height: 12),

                // Nội dung chi tiết quyền lợi
                const Text(
                  "Benefits for cardholders:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  package.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),

                // Nút "Checkout"
                ElevatedButton(
                  onPressed: () {
                    // Lấy userId từ provider
                    final userId = Provider.of<UserInfoProvider>(context, listen: false).userId;
                    print('UserId : ${userId}');

                    // Lấy packageId từ danh sách gói đăng ký
                    final packageId = package.id;

                    Navigator.push(context, MaterialPageRoute(builder: (context) => PayPalPaymentScreen(userId: userId ?? 0,
                      packageId: packageId,)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
