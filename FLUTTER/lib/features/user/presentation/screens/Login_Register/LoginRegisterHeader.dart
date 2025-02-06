import 'package:fitness4life/features/fitness_goal/data/Goal.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/RegisterScreen.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginRegisterHeader extends StatefulWidget {
  const LoginRegisterHeader({Key? key}) : super(key: key);

  @override
  _LoginRegisterHeaderState createState() => _LoginRegisterHeaderState();
}

class _LoginRegisterHeaderState extends State<LoginRegisterHeader> {
  @override
  void initState() {
    super.initState();
    // Gọi các service để tải dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalService = Provider.of<GoalService>(context, listen: false);
      goalService.fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context);
    final userName = Provider.of<UserInfoProvider>(context).userName;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 150,
          color: const Color(0xFFB00020),
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Center(
            child: Text(
              userName != null ? 'Hello, $userName!' : 'Hello customers !',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Kiểm tra trạng thái người dùng và hiển thị widget tương ứng
        Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: userName != null
              ? goalService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: goalService.goals.isNotEmpty
                            ? goalService.goals.map((goal) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: buildGoalCard(goal),
                                );
                              }).toList()
                            : [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child:
                                      buildEmptyGoalCard(), // Hiển thị hiệu ứng khi không có mục tiêu
                                ),
                              ],
                      ),
                    )
              : buildLoginRegister(context),  //Chưa đăng nhập
        ),
      ],
    );
  }

  // Widget hiển thị nút Login và Register
  Widget buildLoginRegister(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Nút Đăng Nhập
          buildLoginRegisterButton(Icons.login_rounded, 'LOGIN', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }),

          // Nút Đăng Ký
          buildLoginRegisterButton(Icons.assignment, 'REGISTER', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          }),
        ],
      ),
    );
  }

  // Hàm tạo nút Đăng Nhập và Đăng Ký
  Widget buildLoginRegisterButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB00020), width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: const Color(0xFFB00020),
            ),
            iconSize: 36,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB00020),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  //Xử lý Goal card
  Widget buildGoalCard(Goal goal) {
    final startDate = goal.startDate != null
        ? DateFormat('d MMM').format(goal.startDate!)
        : 'Unknown';
    final endDate = goal.endDate != null
        ? DateFormat('d MMM').format(goal.endDate!)
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      //color: const Color(0xFF1E1B2E),
      child: Container(
        width: 372,
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left section - Icon/Image
              Container(
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF9747FF),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),

              // Middle section - Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      goal.goalType ?? "Unknown Goal",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.blueGrey,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$startDate - $endDate",
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "7 Spaces left",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Right section - Join button
              Container(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00020),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Xử lý Goal card empty hiển thị animation
  Widget buildEmptyGoalCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      //color: const Color(0xFF1E1B2E),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hiển thị hoạt hình Lottie
            Lottie.asset(
              'animations/Animation.json', // Đường dẫn file JSON
              width: 150,
              height: 50,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 2),
            // Hiển thị thông báo
            const Text(
              "No goals available",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
