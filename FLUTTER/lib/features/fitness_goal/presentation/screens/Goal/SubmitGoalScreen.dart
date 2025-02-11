import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubmitGoalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final goalState = Provider.of<GoalSetupState>(context);

    // Xác định đơn vị đo lường (kg hoặc %)
    bool isKgSelected = goalState.isKgSelected;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Information Goal",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Hiển thị thông tin với đơn vị tương ứng
            buildInfoRow("Goal type", goalState.goalType ?? "No selection"),
            buildInfoRow("Target value", formatValue(goalState.targetValue, isKgSelected)),
            buildInfoRow("Current value", formatValue(goalState.currentValue, isKgSelected)),
            buildInfoRow("Current weight", "${goalState.weight ?? 0} kg"),
            buildInfoRow("Activity level", goalState.activityLevel),
            buildInfoRow("Start time", formatDate(goalState.startDate)),
            buildInfoRow("End time", formatDate(goalState.endDate)),

            SizedBox(height: 30),

            // Nút Submit
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                onPressed: () async {
                  //await goalState.submitGoal(context);
                },
                child: const Text(
                  "Confirm & Send",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Nút quay lại chỉnh sửa
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Come back edit", style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị đơn vị kg hoặc %
  String formatValue(double? value, bool isKg) {
    if (value == null) return "No data";
    return isKg ? "$value kg" : "$value %";
  }

  /// Định dạng ngày từ DateTime ISO sang dạng dễ đọc
  String formatDate(String? isoDate) {
    if (isoDate == null) return "No selection";
    DateTime date = DateTime.parse(isoDate);
    return DateFormat("dd/MM/yyyy").format(date);
  }

  /// Hàm build widget hiển thị thông tin
  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}
