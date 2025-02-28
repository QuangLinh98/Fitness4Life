import 'package:fitness4life/config/constants.dart';
import 'package:fitness4life/core/widgets/SubMenu.dart';
import 'package:fitness4life/features/Home/data/Trainer.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/Home/service/TrainerService.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/smart_deal/presentation/screens/blog/LesmillsBlog.dart';
import 'package:fitness4life/features/smart_deal/presentation/screens/post/Carouse.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginRegisterHeader.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/features/user/service/ProfileService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../user/presentation/screens/Profile/ProfileNotificationBanner.dart';

// Import the notification banner

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi các service để lấy dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi fetchTrainers
      final trainerService = Provider.of<TrainerService>(context, listen: false);
      trainerService.fetchTrainers();

      // Gọi fetchRooms
      final roomService = Provider.of<RoomService>(context, listen: false);
      roomService.fetchRooms();

      // Gọi fetchGoals
      final goalService = Provider.of<GoalService>(context, listen: false);
      goalService.fetchGoals();

      // Fetch user profile if logged in
      final userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
      if (userInfoProvider.userId != null) {
        final profileService = Provider.of<ProfileService>(context, listen: false);
        profileService.getUserById(userInfoProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainerService = Provider.of<TrainerService>(context);   // Lấy trạng thái từ Provider
    final roomService = Provider.of<RoomService>(context);
    final goalService = Provider.of<GoalService>(context);
    final userInfoProvider = Provider.of<UserInfoProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
         Padding(
           padding: const EdgeInsets.only(top: 210),
             child: SingleChildScrollView(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const SubMenu(),   // Menu bên dưới header
                   const SizedBox(height: 16),

                   // Add notification banner if user is logged in
                   if (userInfoProvider.userId != null)
                     const ProfileNotificationBanner(),

                   const Text(
                     "Personal goal this week",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 12),

                   // Phần "Personal goal this week"
                   buildPersonalGoalSection(),

                   const SizedBox(height: 15),
                   const Text(
                     "Personal Trainers",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 15),
                   trainerService.isLoading
                       ? const Center(child: CircularProgressIndicator())
                       : trainerService.trainers.isNotEmpty
                       ? SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: trainerService.trainers.map((trainer) {
                         return Padding(
                           padding:
                           const EdgeInsets.symmetric(horizontal: 8.0),
                           child: buildTrainerAvatar(trainer),
                         );
                       }).toList(),
                     ),
                   )
                       : const Center(
                     child: Text("No trainers available"),
                   ),

                   const SizedBox(height: 15),

                   //Hiển thị Blog
                   const Carouse(),
                   const SizedBox(height: 15),
                   const LesmillsBlog(),
                 ],
               ),
             ),
         ),

          const LoginRegisterHeader(),  //Hiển thị phần đăng ký đăng nhập
        ],
      )
    );
  }

  Widget buildTrainerAvatar(Trainer trainer) {
    String originalUrl = trainer.photo ?? '';
    String correctedUrl = getFullImageUrl(originalUrl);

    // Tách và lấy tên cuối cùng
    String fullName = trainer.fullName ?? "Unknown";
    List<String> nameParts = fullName.split(' '); // Tách chuỗi theo dấu cách
    String lastName = nameParts.isNotEmpty ? nameParts.last : fullName;

    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(correctedUrl),
        ),
        const SizedBox(height: 5),
        Text(lastName, // Hiển thị tên cuối cùng
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  //Xử lý Personal goal this week
  Widget buildPersonalGoalSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Bo góc
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9C9AFF), // Màu tím sáng ở trên
            Color(0xFFB478BD), // Màu tím đậm ở dưới
          ],
        ), // Màu nền tím nhạt
      ),
      padding: const EdgeInsets.all(16), // Padding bên trong
      child: Row(
        children: [
          // Biểu tượng đại diện cho mục tiêu
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.purple[300], // Màu nền biểu tượng
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Colors.white, // Màu của biểu tượng
            ),
          ),
          const SizedBox(width: 16), // Khoảng cách giữa biểu tượng và nội dung
          // Nội dung thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sessions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Màu chữ đen
                  ),
                ),
                const SizedBox(height: 8),
                // Thanh tiến trình
                LinearProgressIndicator(
                  value: 0.4, // Tiến độ (tỉ lệ)
                  minHeight: 8,
                  backgroundColor: Colors.grey[300], // Màu nền của thanh tiến trình
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purple, // Màu tiến trình
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "4 Completed",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Màu chữ đậm
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}