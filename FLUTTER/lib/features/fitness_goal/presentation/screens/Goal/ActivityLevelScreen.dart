import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/SubmitGoalScreen.dart';

class ActivityLevelScreen extends StatelessWidget {
  final List<ActivityLevelModel> activityLevels = [
    ActivityLevelModel("No exercise or very little", "images/yoga.jpg", "SEDENTARY"),
    ActivityLevelModel("Light activity (1-3 days/week)", "images/welcome2.png", "LIGHTLY_ACTIVE"),
    ActivityLevelModel("Moderate activity (3-5 days/week)", "images/selection2.jpg", "MODERATELY_ACTIVE"),
    ActivityLevelModel("High activity (6-7 days/week)", "images/selection3.jpg", "VERY_ACTIVE"),
    ActivityLevelModel("Very high activity (athletes, heavy labor)", "images/selection4.jpg", "EXTREMELY_ACTIVE"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bước 5 trên 18",
          style: TextStyle(color: Colors.orange, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            const Text(
              "Choose your activity level",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: activityLevels.length,
                itemBuilder: (context, index) {
                  return _buildActivityItem(context, activityLevels[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityLevelModel activity) {
    return GestureDetector(
      onTap: () {
        final goalSetupState = Provider.of<GoalSetupState>(context, listen: false);

        // ✅ Lưu `activityLevel` dưới dạng String thay vì `double`
        goalSetupState.setActivityLevel(activity.levelName);

        print("Selected Activity Level: ${goalSetupState.activityLevel}"); // Debug kiểm tra

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubmitGoalScreen()),
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
                    activity.description,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Activity Level: ${activity.levelName}",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(activity.imagePath, width: 80, height: 80, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityLevelModel {
  final String description;
  final String imagePath;
  final String levelName; // ✅ Lưu dạng Enum Name thay vì `double`

  ActivityLevelModel(this.description, this.imagePath, this.levelName);
}
