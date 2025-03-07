import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fitness4life/core/widgets/CustomDialog.dart'; // Import CustomDialog
import 'package:fitness4life/features/fitness_goal/data/Progress/ProgressDTO.dart';
import 'package:fitness4life/features/fitness_goal/service/ProgressService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  double? previousWeight; // Cân nặng trước đó

  @override
  void initState() {
    super.initState();
    selectedMetric = MetricName.WEIGHT;
    trackingDateController.text = trackingDate.toIso8601String().split('T')[0];
  }


  /// **Hàm hiển thị thông báo lỗi**
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// **Hàm xử lý khi nhấn nút Save**
  void saveProgress() async {
    setState(() {
      isLoading = true;
    });

    try {
      final progressService = Provider.of<ProgressService>(context, listen: false);
      final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
      int? userId = userInfo.userId;

      trackingDate = trackingDateController.text.isNotEmpty
          ? DateTime.tryParse(trackingDateController.text) ?? DateTime.now()
          : DateTime.now();

      // Kiểm tra nếu trackingDate là ngày trong tương lai**
      if (trackingDate.isAfter(DateTime.now())) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tracking date cannot be in the future."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      /// Validate giá trị theo dõi
      double? value = double.tryParse(valueController.text);
      if (value == null || value <= 0) {
        showErrorMessage("Value must be greater than 0.");
        return;
      }

      /// Xử lý cân nặng
      double? weight;
      if (selectedMetric == MetricName.WEIGHT) {
        weight = value; // Nếu MetricName là WEIGHT, gán weight bằng value
      } else {
        weight = double.tryParse(weightController.text);
        if (weight == null || weight < 30 || weight > 300) {
          showErrorMessage("Weight must be between 30kg and 300kg.");
          return;
        }
      }

      ProgressDTO progress = ProgressDTO(
        userId: userId ?? 1,
        goal: widget.goalId,
        trackingDate: trackingDate.toIso8601String().split('T')[0],
        metricName: selectedMetric ?? MetricName.WEIGHT,
        value: double.tryParse(valueController.text) ?? 0,
       // weight: double.tryParse(weightController.text),
        weight: weight, // Giá trị weight tự động gán hoặc null
        caloriesConsumed: double.tryParse(caloriesController.text) ?? 0,
      );

      print(" Dữ liệu gửi lên backend: ${progress.toJson()}");
      await progressService.createProgress(progress);

      if (progressService.errorMessage.isEmpty) {
        if (context.mounted) {
          CustomDialog.show(
            context,
            title: "Success",
            content: "Your progress has been saved successfully!",
            buttonText: "OK",
            onButtonPressed: () {
              Navigator.pop(context, true);
            },
          );
        }
      } else {
        print(" API Error: ${progressService.errorMessage}");
        if (context.mounted) {
          CustomDialog.show(
            context,
            title: "Error",
            content: progressService.errorMessage,
            buttonText: "OK",
          );
        }
      }
    } catch (e) {
      print(" Exception: ${extractErrorMessage(e)}");
      if (context.mounted) {
        CustomDialog.show(
          context,
          title: "Error",
          content: extractErrorMessage(e),
          buttonText: "OK",
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  /// **Hàm lấy lỗi từ backend hoặc Exception**
  String extractErrorMessage(dynamic error) {
    if (error is String) {
      return error; // Nếu lỗi là chuỗi, trả về trực tiếp
    } else if (error is Exception) {
      final message = error.toString();
      if (message.contains("Failed to create progress:")) {
        // Tách lấy message từ "Failed to book room:"
        return message.split("Failed to create progress:")[1].trim();
      } else if (message.contains("Exception:")) {
        // Tách bỏ từ "Exception:"
        return message.split("Exception:")[1].trim();
      }
      return message; // Trả về toàn bộ chuỗi nếu không tách được
    } else {
      return "An unexpected error occurred. Please try again."; // Thông báo mặc định
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
                  child: Text(metric.toString().split('.').last),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            // TextFormField(
            //   controller: weightController,
            //   decoration: const InputDecoration(
            //     labelText: 'Weight',
            //     border: OutlineInputBorder(),
            //   ),
            //   keyboardType: TextInputType.number,
            // ),
            // Cân nặng (chỉ hiển thị nếu MetricName != WEIGHT)
            if (selectedMetric != MetricName.WEIGHT) ...[
              Text("Previous Weight: ${previousWeight != null ? "${previousWeight!} kg" : 'No data'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'New Weight',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],

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
                  //lastDate: DateTime(2100),
                  lastDate: DateTime.now(),
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
                  onPressed: isLoading ? null : saveProgress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
