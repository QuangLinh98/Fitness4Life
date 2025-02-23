import 'package:fitness4life/config/constants.dart';
import 'package:fitness4life/core/widgets/SubMenu.dart';
import 'package:fitness4life/features/Home/data/Trainer.dart';
import 'package:fitness4life/features/Home/service/RoomService.dart';
import 'package:fitness4life/features/Home/service/TrainerService.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/smart_deal/presentation/screens/post/Carouse.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginRegisterHeader.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/LanguageProvider.dart';
import '../../../smart_deal/presentation/screens/blog/LesmillsBlog.dart';


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

      // final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
      // String? userName = userInfo.userName;
      // int? userId = userInfo.userId;
      // print("data của userInfo name = ${userName} id = ${userId}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainerService = Provider.of<TrainerService>(context);   // Lấy trạng thái từ Provider
    final roomService = Provider.of<RoomService>(context);
    final goalService = Provider.of<GoalService>(context);

    // thêm
    final isVietnamese = Provider.of<LanguageProvider>(context).isVietnamese;
    return Scaffold(
      body: Stack(
        children: [
         Padding(
           padding: const EdgeInsets.only(top: 210),
             child:SingleChildScrollView(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const SubMenu(),   // Menu bên dưới header
                   const SizedBox(height: 16),
                   Text(
                     isVietnamese ? "Mục tiêu cá nhân tuần này" : "Personal goal this week",
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 12),

                   // Phần "Personal goal this week"
                   buildPersonalGoalSection(),
                   const SizedBox(height: 15),
                   Text(
                     isVietnamese ? "Huấn luyện viên cá nhân" : "Personal Trainers",
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                   ) : Center(
                     child: Text(
                         isVietnamese ? "Không có huấn luyện viên nào" : "No trainers available"
                     ),
                   ),

                   const SizedBox(height: 15),

                   Text(
                     isVietnamese ? "Thử thách sắp tới" : "Upcoming Challenges",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 10),
                   goalService.isLoading
                       ? const Center(child: CircularProgressIndicator())
                       : goalService.goals.isNotEmpty
                       ? SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: goalService.goals.map((goal) {
                         return Padding(
                           padding:
                           const EdgeInsets.symmetric(horizontal: 8.0),
                           child: buildGoalCard(goal),
                         );
                       }).toList(),
                     ),
                   )
                       : Center(
                     child: Text( isVietnamese ? "Không có thử thách nào" : "No goal available",),
                   ),

                   const SizedBox(height: 15),
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


  //Xử lý Personal Trainers
  Widget buildTrainerAvatar(Trainer trainer) {
    String originalUrl = trainer.photo ?? '';
    String correctedUrl = getFullImageUrl(originalUrl);

    // thêm
    final isVietnamese = Provider.of<LanguageProvider>(context, listen: false).isVietnamese;

    // Tách và lấy tên cuối cùng
    String fullName = trainer.fullname ?? (isVietnamese ? "Không rõ" : "Unknown");
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

  //Xử lý Upcoming Challenges
  Widget buildGoalCard(Goal goal) {
    // thêm
    final isVietnamese = Provider.of<LanguageProvider>(context, listen: false).isVietnamese;

    final startDate = goal.startDate != null
        ? DateFormat('d MMM').format(goal.startDate!)
        : (isVietnamese ? 'Không rõ' : 'Unknown');
    final endDate = goal.endDate != null
        ? DateFormat('d MMM').format(goal.endDate!)
        : (isVietnamese ? 'Không rõ' : 'Unknown');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: const Color(0xFF1E1B2E),
      child: Container(
        width: 372,
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left section - Icon/Image
              Container(
                width: 80,
                height: 60,
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
                      goal.goalType ?? (isVietnamese ? "Mục tiêu chưa xác định" : "Unknown Goal"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$startDate - $endDate",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVietnamese ? "Còn 7 chỗ" : "7 Spaces left",
                      style: TextStyle(
                        color: Colors.white54,
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
                  onPressed: () {
                    final userId = Provider.of<UserInfoProvider>(context, listen: false).userId;
                    // print('UserId : ${userId}');

                    //Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen(userId: userId )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9747FF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isVietnamese ? 'Tham gia' : 'Join',
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


  //Xử lý Personal goal this week
  Widget buildPersonalGoalSection() {
    final isVietnamese = Provider.of<LanguageProvider>(context, listen: false).isVietnamese;
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
                 Text(
                  isVietnamese ? "Buổi tập" : "Sessions",
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
                Text(
                  isVietnamese ? "4 Buổi hoàn thành" : "4 Completed",
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