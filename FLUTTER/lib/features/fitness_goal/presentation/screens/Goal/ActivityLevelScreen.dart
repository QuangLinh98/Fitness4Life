import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/StartDateScreen.dart';
import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatelessWidget {
  final List<ActivityLevelModel> activityLevels = [
    ActivityLevelModel("No exercise or very little", "images/yoga.jpg", 1.2),
    ActivityLevelModel("Light activity (1-3 days/week)", "images/welcome2.png", 1.375),
    ActivityLevelModel("Moderate activity (3-5 days/week)", "images/selection2.jpg", 1.55),
    ActivityLevelModel("High activity (6-7 days/week)", "images/selection3.jpg", 1.725),
    ActivityLevelModel("Very high activity (athletes, heavy labor)", "images/selection4.jpg", 1.9),
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
        title: Text(
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
            Text(
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
        // Lưu lựa chọn và chuyển sang màn hình tiếp theo
        Navigator.push(context, MaterialPageRoute(builder: (context) => StartDateScreen()));
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
                    "Movement index: ${activity.multiplier}",
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
  final double multiplier;

  ActivityLevelModel(this.description, this.imagePath, this.multiplier);
}
