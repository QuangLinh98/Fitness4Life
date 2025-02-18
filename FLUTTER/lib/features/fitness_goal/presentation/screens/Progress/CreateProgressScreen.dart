import 'package:fitness4life/features/fitness_goal/data/Progress/ProgressDTO.dart';
import 'package:fitness4life/features/fitness_goal/service/ProgressService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ProgressScreen.dart';

class CreateProgressScreen extends StatefulWidget {
  final int goalId;
  CreateProgressScreen({super.key, required this.goalId});

  @override
  _CreateProgressScreenState createState() => _CreateProgressScreenState();
}

class _CreateProgressScreenState extends State<CreateProgressScreen> {
  bool isLoading = false;
  MetricName? selectedMetric;

  TextEditingController caloriesController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController trackingDateController = TextEditingController();
  DateTime trackingDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedMetric = MetricName.WEIGHT;
    trackingDateController.text = trackingDate.toIso8601String().split('T')[0];
  }

  Future<void> _submitProgress() async {
    setState(() {
      isLoading = true;
    });

    try {
      final progressService = Provider.of<ProgressService>(context, listen: false);
      final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
      int? userId = userInfo.userId;

      // Cập nhật trackingDate từ TextFormField trước khi gửi
      trackingDate = trackingDateController.text.isNotEmpty
          ? DateTime.tryParse(trackingDateController.text) ?? DateTime.now()
          : DateTime.now();

      ProgressDTO progress = ProgressDTO(
        userId: userId ?? 1,
        goal: widget.goalId,
        trackingDate: trackingDate.toIso8601String().split('T')[0],
        metricName: selectedMetric ?? MetricName.WEIGHT,
        value: double.tryParse(valueController.text) ?? 0,
        weight: double.tryParse(weightController.text),
        caloriesConsumed: double.tryParse(caloriesController.text) ?? 0,
      );
      print("Dữ liệu gửi lên backend: ${progress.toJson()}");
      await progressService.createProgress(progress);

      if (progressService.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Progress created successfully!")),
        );
        // ✅ Chuyển về ProgressScreen sau khi tạo thành công
        Navigator.pop(context, true); // ✅ Quay lại màn hình trước (ProgressScreen)

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(progressService.errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00020),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<MetricName>(
              value: selectedMetric,
              decoration: const InputDecoration(
                labelText: 'Metric Name',
                border: OutlineInputBorder(),
              ),
              items: MetricName.values.map((MetricName metric) {
                return DropdownMenuItem<MetricName>(
                  value: metric,
                  child: Text(metric.toString().split('.').last), // Hiển thị tên enum
                );
              }).toList(),
              onChanged: (MetricName? newValue) {
                setState(() {
                  selectedMetric = newValue!;
                });
              },
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories consumed',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value to track',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: trackingDateController,
              decoration: const InputDecoration(
                labelText: 'Tracking Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: trackingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    trackingDate = pickedDate;
                    trackingDateController.text = trackingDate.toIso8601String().split('T')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitProgress,
                  child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
