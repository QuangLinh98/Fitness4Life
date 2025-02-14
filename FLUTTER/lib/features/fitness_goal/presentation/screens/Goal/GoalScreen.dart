import 'dart:ui';

import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/GoalSuccessScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Progress/ProgressScreen.dart';
import 'package:fitness4life/features/fitness_goal/service/GoalService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch goals after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalService = Provider.of<GoalService>(context, listen: false);
      goalService.fetchGoals(); // Fetch goals when screen loads
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalService = Provider.of<GoalService>(context);

    return Scaffold(
      body: goalService.isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator while data is fetching
          : ListView.builder(
        itemCount: goalService.goals.length, // Total number of goals
        itemBuilder: (context, index) {
          final goal = goalService.goals[index];
          return buildGoalCard(goal); // Build a card for each goal
        },
      ),
    );
  }

  // Function to display goal information in a Card
  Widget buildGoalCard(Goal goal) {
    final startDate = goal.startDate != null
        ? DateFormat('d MMM').format(goal.startDate!)
        : 'Unknown';
    final endDate = goal.endDate != null
        ? DateFormat('d MMM').format(goal.endDate!)
        : 'Unknown';

    // Lấy dữ liệu trọng lượng
    double weight = goal.weight?.toDouble() ?? 0.0;
    double currentValue = goal.currentValue?.toDouble() ?? 0.0;
    double targetValue = goal.targetValue?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () {
        // Khi người dùng chạm vào card, chuyển đến ProgressScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProgressScreen()),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        color: const Color(0xFFC0C0C0),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left section - Icon/Image
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        color: const Color(0xFFC0C0C0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        goal.goalType ?? "Unknown Goal",
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
                                      const Text(
                                        "7 Spaces left",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Join button Section
                    Container(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          final goalId = goal.id;

                          Navigator.push(context, MaterialPageRoute(builder: (context) => GoalSuccessScreen(goalId: goalId!)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9747FF),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Detail',
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

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100, // Adjusted the height to fit the chart
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: weight,
                                    color: Colors.blue,
                                    width: 22,
                                    borderRadius: BorderRadius.vertical(),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: currentValue,
                                    color: Colors.green,
                                    width: 22,
                                    borderRadius: BorderRadius.vertical(),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: targetValue,
                                    color: Colors.orange,
                                    width: 22,
                                    borderRadius: BorderRadius.vertical(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Legend (Chú thích)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendBox(Colors.blue, "Weight"),
                        _buildLegendBox(Colors.green, "Current Value"),
                        _buildLegendBox(Colors.orange, "Target Value"),
                      ],
                    ),
                  ],
                )
                // Chart Section
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to create legend box for each color and label
  Widget _buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
