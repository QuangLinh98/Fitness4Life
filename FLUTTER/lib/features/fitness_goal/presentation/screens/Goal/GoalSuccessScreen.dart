import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/DashboardScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/GoalScreen.dart';
import 'package:flutter/material.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:provider/provider.dart';

class GoalSuccessScreen extends StatefulWidget {
  final int goalId;

  GoalSuccessScreen({required this.goalId});

  @override
  _GoalSuccessScreenState createState() => _GoalSuccessScreenState();
}

class _GoalSuccessScreenState extends State<GoalSuccessScreen> {
  Goal? goal;
  double? bmi;

  @override
  void initState() {
    super.initState();

    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    final userId = userInfo.userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalService = Provider.of<GoalService>(context, listen: false);

      goalService.getGoalById(widget.goalId).then((goalData) {
        setState(() {
          goal = goalData;
        });

        final weight = goal?.weight;
        if (weight != null && userId != null) {
          goalService.getBMI(weight, userId).then((bmiData) {
            setState(() {
              bmi = bmiData;
            });
          }).catchError((e) {
            print("Error fetching BMI: $e");
          });
        }
      }).catchError((e) {
        print("Error fetching goal: $e");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán chỉ số BMI và xác định màu sắc của thanh BMI
    double bmiValue = bmi ?? 0.0;
    String bmiStatus = 'Normal'; // Mặc định
    Color bmiColor = Colors.green; // Mặc định


    if (bmiValue < 18.5) {
      bmiStatus = 'Underweight';
      bmiColor = Colors.orange;
    } else if (bmiValue >= 25) {
      bmiStatus = 'Obesity';
      bmiColor = Colors.red;
    }

    // Xác định vị trí của chỉ thị trên thanh BMI
    double bmiPosition = bmiValue < 18.5
        ? 0.0
        : bmiValue >= 25
        ? 1.0
        : (bmiValue - 18.5) / (24.9 - 18.5);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
              'Information Goal',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tiến trình BMI
            _buildBmiIndicator(bmiValue, bmiStatus, bmiColor, bmiPosition),

            SizedBox(height: 20),

            // Hiển thị hình ảnh người và thông tin goal ngang nhau
            _buildInfoRow('Goal type:', '${goal?.goalType}'),
            _buildInfoRow('Weight:', '${goal?.weight} kg'),
            _buildInfoRow('Current Value:', '${goal?.currentValue} kg'),
            _buildInfoRow('Target Value:', '${goal?.targetValue} kg'),
            _buildInfoRow('Activity Level:', goal?.activityLevel ?? "Not specified"),
            _buildInfoRow('Target Calories:', '${goal?.targetCalories != null ? goal!.targetCalories!.toStringAsFixed(2) : 'N/A'} cal/day'),
            _buildInfoRow('Goal Status:', goal?.goalStatus ?? "PLANNING"),

            SizedBox(height: 20),

            // Diet and workout plans
            const Text(
              'Diet and Workout Plans:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),  // Màu chữ trắng
            ),
            ...goal!.dietPlans.map((dietPlan) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diet Plan: ${dietPlan.dietPlan}',
                    style: TextStyle(fontSize: 16, color: Colors.white),  // Màu chữ trắng
                  ),
                  Text(
                    'Workout Plan: ${dietPlan.workoutPlan}',
                    style: TextStyle(fontSize: 16, color: Colors.white),  // Màu chữ trắng
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),

            const SizedBox(height: 30),

            // Nút tiếp tục
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
                  debugPrint("Current widget context: ${context.widget}");
                },
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiIndicator(double bmiValue, String bmiStatus, Color bmiColor, double bmiPosition) {
    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current BMI', style: TextStyle(fontSize: 16, color: Colors.white)),  // Màu chữ trắng
              Text(
                '${bmiValue.toStringAsFixed(1)} BMI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),  // Màu chữ trắng
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 10, // Chiều cao của thanh tiến trình BMI
            decoration: BoxDecoration(
              color: Colors.grey[200], // Màu nền xám nhạt cho phần background
              borderRadius: BorderRadius.circular(8), // Bo tròn các góc của container ngoài
            ),
            child: Stack(
              children: [
                // Sử dụng container con để tạo thanh tiến trình BMI
                Container(
                  height: 10, // Đảm bảo chiều cao của thanh tiến trình BMI
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), // Bo góc thanh tiến trình
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                // Mũi tên chỉ vị trí BMI
                Positioned(
                  left: (MediaQuery.of(context).size.width - 32) * bmiPosition,
                  top: -5,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: bmiColor, // Màu mũi tên sẽ thay đổi theo BMI
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 5),
          Text(
            bmiStatus,
            style: TextStyle(fontSize: 16, color: bmiColor),  // Màu chữ BMI status sẽ thay đổi
          ),
        ],
      );

  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        color: Color(0x7A7979FF),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),  // Màu chữ trắng
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),  // Màu chữ trắng
            ),
          ],
        ),
      ),
    );
  }
}

