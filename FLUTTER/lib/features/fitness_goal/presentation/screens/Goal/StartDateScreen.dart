import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/EndDateScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/TargetValueScreen.dart';
import 'package:intl/intl.dart';

class StartDateScreen extends StatefulWidget {
  @override
  _StartDateScreenState createState() => _StartDateScreenState();
}

class _StartDateScreenState extends State<StartDateScreen> {
  DateTime selectedDate = DateTime(2025, 1, 1); // Mặc định 01/01/2025

  @override
  Widget build(BuildContext context) {
    final goalSetupState = Provider.of<GoalSetupState>(context, listen: false);

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
          "Bước 6 trên 15",
          style: TextStyle(color: Colors.orange, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            const Text(
              "When is your start date?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            const Text(
              "We need to know your start date to plan accurately.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 30),

            // Hiển thị ngày tháng năm đã chọn
            Center(
              child: Text(
                DateFormat("dd/MM/yyyy").format(selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            // Picker chọn ngày tháng năm
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Brightness.dark, // Đảm bảo hiển thị rõ ràng trên nền tối
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white, // Đảm bảo màu chữ sáng
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _getValidInitialDate(selectedDate),
                  minimumDate: DateTime(2020, 1, 1),
                  maximumDate: DateTime(2030, 12, 31),
                  backgroundColor: Colors.black, // Đảm bảo nền không gây lỗi hiển thị
                  onDateTimeChanged: (DateTime newDate) {
                    if (newDate.year >= 2020 && newDate.year <= 2030) {
                      setState(() {
                        selectedDate = newDate;
                      });
                      goalSetupState.setStartDate(newDate.toIso8601String());
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 20),

            // Nút "Tiếp tục"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  print("Start Date before moving: ${goalSetupState.startDate}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EndDateScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Hàm điều chỉnh ngày hợp lệ nếu nằm ngoài phạm vi
  DateTime _getValidInitialDate(DateTime date) {
    if (date.year < 2020) return DateTime(2020, date.month, date.day);
    if (date.year > 2030) return DateTime(2030, date.month, date.day);
    return date;
  }
}
