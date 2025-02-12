import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/smartDeal/presentation/screens/post/YourPost.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/Password/ChangePasswordScreen.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../smartDeal/presentation/screens/promotion/PromotionScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 16),
                  // User Information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bảo Anh",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Hồ sơ >",
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

            // Account Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 377,
                decoration: BoxDecoration(
                  color: const Color(0xFFB00020),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HO_MB211118321290",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Bảo Anh_Signature",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Ngày kích hoạt: 18/11/2021",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ngày kết thúc: 17/11/2023",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Options List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildOptionItem("Hướng dẫn sử dụng", Icons.help_outline, () {}),
                buildOptionItem("mã khuyến mãi ", Icons.code, () {
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
                buildOptionItem("Liên hệ", Icons.phone, () {}),
                buildOptionItem("Hợp đồng", Icons.description_outlined, () {}),
                buildOptionItem("Lịch sử chăm sóc khách hàng", Icons.history, () {}),
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
