  import 'package:fitness4life/features/fitness_goal/data/Goal/CreateGoal.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
  import 'package:flutter/material.dart';
  import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
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

      final goalState = Provider.of<GoalSetupState>(context, listen: false);
      final weight = goalState.weight;
      print('Weight : $weight');
      print('Goal State : $goalState');

      final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
      final userId = userInfo.userId;

      // Gọi các service để lấy dữ liệu goal từ API
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final goalService = Provider.of<GoalService>(context, listen: false);

        // Gọi service để lấy dữ liệu goal theo goalId
        goalService.getGoalById(widget.goalId!).then((goalData) {
          setState(() {
            goal = goalData;  // Cập nhật dữ liệu goal vào UI
          });
        }).catchError((e) {
          print("Error fetching goal: $e");
        });

        // Gọi service để lấy dữ liệu BMI từ backend
        if (weight != null && userId != null) {
          goalService.getBMI(weight, userId).then((bmiData) {
            setState(() {
              bmi = bmiData;  // Cập nhật BMI từ backend vào UI
            });
          }).catchError((e) {
            print("Error fetching BMI: $e");
          });
        }
      });
    }

    @override
    Widget build(BuildContext context) {
      if (goal == null  ) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Goal Submission Successful'),
            backgroundColor: Colors.green,
          ),
          body: Center(
            child: CircularProgressIndicator(), // Hiển thị khi đang tải dữ liệu
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Goal Submission Successful'),
          backgroundColor: Colors.green,
        ),
        body:
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Congratulations on setting your goal!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildInfoRow('BMI:', bmi != null ? bmi!.toStringAsFixed(2) : 'BMI not available'),
              _buildInfoRow('Goal type:', '${goal?.goalType}'),
              _buildInfoRow('Weight:', '${goal?.weight} kg'),
              _buildInfoRow('Current Value:', '${goal?.currentValue} kg'),
              _buildInfoRow('Target Value:', '${goal?.targetValue} kg'),
              _buildInfoRow('Activity Level:', goal?.activityLevel ?? "Not specified"),
              _buildInfoRow('Goal Status:', goal?.goalStatus ?? "PLANNING"),
              _buildInfoRow('Target Calories:', '${goal?.targetCalories} cal/day'),

              // Hiển thị dietPlan và workoutPlan từ dietPlans
              SizedBox(height: 20),
              const Text(
                'Diet and Workout Plans:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...goal!.dietPlans.map((dietPlan) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diet Plan: ${dietPlan.dietPlan}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Workout Plan: ${dietPlan.workoutPlan}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }).toList(),

              SizedBox(height: 20),
              const Text(
                'Your Body Statistics:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Chuyển đến màn hình tiếp theo hoặc thực hiện hành động khác
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

    Widget _buildInfoRow(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }

