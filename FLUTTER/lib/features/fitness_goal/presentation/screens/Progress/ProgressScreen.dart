import 'package:fitness4life/features/fitness_goal/data/Goal/Goal.dart';
import 'package:fitness4life/features/fitness_goal/data/Progress/Progress.dart';
import 'package:fitness4life/features/fitness_goal/service/ProgressService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class ProgressScreen extends StatefulWidget {
  final int goalId;
  final Goal goal;

  ProgressScreen({super.key, required this.goalId, required this.goal});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late PageController _pageController;
  int _currentPage = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressService>(context, listen: false).fetchProgressByGoalId(widget.goalId);
    });

    // Lắng nghe thay đổi trang
    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage && mounted) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressService = Provider.of<ProgressService>(context);
    final progressList = progressService.progress;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          progressList.isNotEmpty
              ? DateFormat('E, dd MMM').format(progressList[_currentPage].trackingDate!)
              : "Progress",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFB00020),
        centerTitle: true,
      ),
      body: progressService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : progressService.errorMessage.isNotEmpty
          ? Center(child: Text(progressService.errorMessage))
          : progressList.isEmpty
          ? const Center(child: Text("No progress data available"))
          : PageView.builder(
        controller: _pageController,
        itemCount: progressList.length,
        itemBuilder: (context, index) {
          return _buildProgressPage(progressList[index],widget.goal, index, progressList.length);
        },
      ),
    );
  }

  /// **Hiển thị từng trang dữ liệu Progress**
  Widget _buildProgressPage(Progress progress, Goal goal, int index, int totalPages) {
    return SingleChildScrollView(
      key: ValueKey(progress.id), // Đảm bảo mỗi trang có Key duy nhất
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressCard(progress, goal.targetCalories ?? 2000.0),
          const SizedBox(height: 20),
          _buildWeightAndValueCards(progress,goal),
          const SizedBox(height: 20),
          _buildNavigationButtons(index, totalPages),
          const SizedBox(height: 20),
          _buildChartCard(goal, index)
        ],
      ),
    );
  }

  /// **Card hiển thị tổng calo tiêu thụ**
  Widget _buildProgressCard(Progress progress, double targetCalories) {
    double caloriesConsumed = progress.caloriesConsumed;
    double percentage = (caloriesConsumed / targetCalories).clamp(0.0, 1.0); // Giữ tỷ lệ trong 0-1

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),

            /// **Hiển thị Calories Consumed & Target Calories**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${caloriesConsumed.toStringAsFixed(1)} / ${targetCalories.toStringAsFixed(1)} Cal',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Calo/day'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// **Progress bar hiển thị mức độ tiêu thụ Calories**
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: percentage,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  caloriesConsumed > targetCalories ? Colors.red : Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// **Hiển thị message về Calories**
            if (progress.message != null && progress.message!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  progress.message!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// **Card hiển thị cân nặng và chỉ số**
  Widget _buildWeightAndValueCards(Progress progress,Goal goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn chỉnh khoảng cách đều
      children: [
        Expanded(
          child: _buildCard('Weight', '${goal.weight?.toStringAsFixed(1) ?? "N/A"} kg', 'Initial Weight'),
        ),
        const SizedBox(width: 8), // Giảm khoảng cách giữa các cột
        Expanded(
          child: _buildCard('Value', '${progress.value?.toStringAsFixed(1) ?? "N/A"}', 'Current Value'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard('Target', '${goal.targetValue?.toStringAsFixed(1) ?? "N/A"}', 'Target Value'),
        ),
      ],
    );
  }

  /// **Tạo Card chung**
  Widget _buildCard(String title, String value, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// **Nút điều hướng giữa các trang**
  Widget _buildNavigationButtons(int currentIndex, int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentIndex > 0
              ? () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
              : null,
          child: const Icon(Icons.arrow_back),
        ),
        Text("${currentIndex + 1} / $totalPages", style: const TextStyle(fontSize: 16)),
        ElevatedButton(
          onPressed: currentIndex < totalPages - 1
              ? () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
              : null,
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
  
  /// Biều đồ chart của gias trị progress
  Widget _buildChartCard(Goal goal, int currentIndex) {
    List<FlSpot> spots = [];

    print("🟢 Goal ID: ${goal.id}");
    print("🟢 Progress history length: ${goal.progress.length}");
    print("🟢 Raw progress data: ${goal.progress}");

    // ✅ Kiểm tra nếu progressHistory rỗng
    if (goal.progress.isNotEmpty) {
      // Tạo danh sách dữ liệu dựa trên lịch sử progress
      for (int i = 0; i <= currentIndex && i < goal.progress.length; i++) {
        double xValue = i.toDouble();
        double yValue = goal.progress[i].value ?? 0;
        spots.add(FlSpot(xValue, yValue));
      }
    }
    print("🟢 Spots data: $spots");
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Progress vs. Target",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toStringAsFixed(0)} kg');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          return Text('Day ${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Line hiển thị Progress
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Line hiển thị Target
                    LineChartBarData(
                      spots: spots.map((e) => FlSpot(e.x, goal.targetValue ?? 0)).toList(),
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dashArray: [5, 5], // ✅ Dashed line
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
