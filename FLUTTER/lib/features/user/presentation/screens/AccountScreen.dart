import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/booking/data/MembershipSubscription%20.dart';
import 'package:fitness4life/features/booking/service/MembershipSubscriptionService.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/Password/ChangePasswordScreen.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../smart_deal/presentation/screens/RewardProgramPage.dart';
import '../../../smart_deal/presentation/screens/post/YourPost.dart';
import '../../../smart_deal/presentation/screens/promotion/PromotionScreen.dart';

class AccountScreen extends StatefulWidget {
  final int userId;
  const AccountScreen({super.key,  this.userId = 102});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  MembershipSubscription? memberShipData; // Biến lưu trữ thông tin QR
  bool isLoading = true; // Trạng thái chờ

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Gọi các service để lấy dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final membershipService = Provider.of<MembershipSubscriptionService>(context, listen: false);
      membershipService.getMembershipSubscription(widget.userId); // 🔹 Chỉ gọi API, không dùng setState()
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserInfoProvider>(context).userName;
    final membershipService = Provider.of<MembershipSubscriptionService>(context);
    final membership = membershipService.membershipSubscription;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: const Color(0xFFB00020),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName != null ? '$userName!' : 'Hello customers !',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Profile >",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Account Info Section (Hiển thị Membership)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 377,
                decoration: BoxDecoration(
                  color: const Color(0xFFB00020),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<MembershipSubscriptionService>(
                  builder: (context, membershipService, child) {
                    final membership = membershipService.membershipSubscription;

                    // 🔥 Kiểm tra xem có lỗi không
                    if (membershipService.errorMessage != null) {
                      return Text(
                        "❌ Error: ${membershipService.errorMessage}",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      );
                    }

                    // 🔥 Kiểm tra xem Membership có null không
                    if (membership == null) {
                      print("⏳ Membership vẫn chưa có dữ liệu, đang loading...");
                      return const Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          Text("🔄 Loading...", style: TextStyle(color: Colors.white)),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${membership.transactionId}",
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text(
                                "Membership: ${membership.membershipLevel}",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${NumberFormat('#,###').format(membership.amount)} USD",
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ]
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Activation Date: ${membership.formattedTransactionDate}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Expiration Date: ${membership.formattedExpirationDate}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 4),

                      ],
                    );
                  },
                ),

              ),
            ),

            // Options List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildOptionItem("User Guide", Icons.help_outline, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RewardProgramPage())
                  );
                }),
                buildOptionItem("Your Discount", Icons.code, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PromotionScreen())
                  );
                }),
                buildOptionItem("Your Post", Icons.post_add_sharp, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YourPost())
                  );
                }),
                buildOptionItem("Contact", Icons.phone, () {}),
                buildOptionItem("Contract", Icons.description_outlined, () {}),
                buildOptionItem("Customer Care History", Icons.history, () {}),
                buildOptionItem("Change password", Icons.lock_outline, ()  {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen())
                  );
                }),
                buildOptionItem("Logout", Icons.logout, ()async {
                  await handleLogout(context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to Build Each Option Item
  Widget buildOptionItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  //Xử lý logout
  Future<void> handleLogout(BuildContext context) async {
    try {
      // Gọi hàm logout từ LoginService
      final loginService = Provider.of<LoginService>(context, listen: false);
      await loginService.logout();

      // Điều hướng về màn hình đăng nhập
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen())
      );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu logout thất bại
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Logout failed"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }

}