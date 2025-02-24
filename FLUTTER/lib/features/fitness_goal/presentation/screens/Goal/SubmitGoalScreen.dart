import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/GoalSuccessScreen.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SubmitGoalScreen extends StatefulWidget {
  @override
  _SubmitGoalScreenState createState() => _SubmitGoalScreenState();
}

class _SubmitGoalScreenState extends State<SubmitGoalScreen> {
  bool _isSubmitting = false; // Trạng thái loader

  @override
  Widget build(BuildContext context) {
    final goalState = Provider.of<GoalSetupState>(context);
    final goalService = Provider.of<GoalService>(context);

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

            buildInfoRow("Goal type", goalState.goalType ?? "No selection"),
            buildInfoRow("Target value", formatValue(goalState.targetValue, isKgSelected)),
            buildInfoRow("Current value", formatValue(goalState.currentValue, isKgSelected)),
            buildInfoRow("Current weight", "${goalState.weight ?? 0} kg"),
            buildInfoRow("Activity level", goalState.activityLevel),
            buildInfoRow("Start time", formatDate(goalState.startDate)),
            buildInfoRow("End time", formatDate(goalState.endDate)),

            SizedBox(height: 30),

            // Nút Submit với Loader
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                onPressed: _isSubmitting ? null : () async { // Vô hiệu hóa nếu đang gửi dữ liệu
                  setState(() {
                    _isSubmitting = true; // Bắt đầu hiển thị loader
                  });

                  try {
                    await _submitGoal(context, goalService, goalState);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Goal submitted successfully!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to submit goal: $e')));
                  } finally {
                    setState(() {
                      _isSubmitting = false; // Tắt loader khi xong
                    });
                  }
                },
                child: _isSubmitting
                    ? CircularProgressIndicator( // Hiển thị loader
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  "Confirm & Send",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  if (!_isSubmitting) { // Ngăn người dùng quay lại khi đang submit
                    Navigator.pop(context);
                  }
                },
                child: Text("Come back edit", style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Các hàm hỗ trợ (không thay đổi)
  String formatValue(double? value, bool isKg) {
    if (value == null) return "No data";
    return isKg ? "$value kg" : "$value %";
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return "No selection";
    DateTime date = DateTime.parse(isoDate);
    return DateFormat("dd/MM/yyyy").format(date);
  }

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

  Future<void> _submitGoal(BuildContext context, GoalService goalService, GoalSetupState goalState) async {
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    int? userId = userInfo.userId;

    GoalDTO goalDTO = GoalDTO(
      userId: userId!,
      goalType: _getGoalTypeFromString(goalState.goalType ?? "MUSCLE_GAIN"),
      targetValue: goalState.targetValue ?? 0.0,
      currentValue: goalState.currentValue ?? 0.0,
      weight: goalState.weight ?? 0.0,
      startDate: _parseDate(goalState.startDate),
      endDate: _parseDate(goalState.endDate),
      activityLevel: _getActivityLevelFromString(goalState.activityLevel),
    );

    Map<String, dynamic> goalData = Map.from(goalDTO.toJson());
    goalData.remove('goalStatus');
    goalData.remove('createdAt');

    await goalService.submitGoal(context, goalDTO);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalSuccessScreen(goalId: goalState.goalId!),
      ),
    ).then((_) {
      PageManager.of(context)?.updateIndex(2);
    });
  }

  GoalType _getGoalTypeFromString(String goalType) {
    return GoalType.values.firstWhere((e) => e.toString().split('.').last == goalType, orElse: () => GoalType.MUSCLE_GAIN);
  }

  ActivityLevel _getActivityLevelFromString(String activityLevel) {
    return ActivityLevel.values.firstWhere((e) => e.toString().split('.').last == activityLevel, orElse: () => ActivityLevel.SEDENTARY);
  }

  DateTime _parseDate(String? date) {
    if (date == null || date == "No selection") {
      return DateTime.now();
    }
    return DateTime.parse(date);
  }
}

