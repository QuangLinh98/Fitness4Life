import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/CurrentWeightScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/TargetWeightScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Chọn mục tiêu chính của bạn",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bước 1 trên 18",
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildGoalItem(
                    context,
                    "Tăng cơ bắp",
                    "và loại bỏ chất béo",
                    "images/selection2.jpg",
                    "MUSCLE_GAIN",
                  ),
                  _buildGoalItem(
                    context,
                    "Giảm cân",
                    "không bị mất cơ",
                    "images/selection2.jpg",
                    "WEIGHT_LOSS",
                  ),
                  _buildGoalItem(
                    context,
                    "Cắt nét cơ",
                    "và giữ dáng",
                    "images/selection2.jpg",
                    "MUSCLE_CUT",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, String title, String subtitle, String imagePath, String goalType) {
    return GestureDetector(
      onTap: () {
        // Lưu mục tiêu vào GoalSetupState
        Provider.of<GoalSetupState>(context, listen: false).setGoalType(goalType);

        // Chuyển sang TargetWeightScreen và truyền dữ liệu
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CurrentWeightScreen(goalType: goalType),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
