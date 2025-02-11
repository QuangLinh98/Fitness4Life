import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/TargetWeightScreen.dart';
import 'package:intl/intl.dart'; // Thư viện hỗ trợ format ngày

class StartDateScreen extends StatefulWidget {
  @override
  _StartDateScreenState createState() => _StartDateScreenState();
}

class _StartDateScreenState extends State<StartDateScreen> {
  DateTime selectedDate = DateTime.now();

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
        title: Text(
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
            Text(
              "When is your start date?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We need to know your start date to plan accurately.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 30),

            // Hiển thị ngày tháng năm đã chọn
            Center(
              child: Text(
                DateFormat("dd/MM/yyyy").format(selectedDate),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            // Picker chọn ngày tháng năm
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime.now().add(Duration(days: 365 * 5)), // Tối đa 5 năm sau
                backgroundColor: Colors.black,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    selectedDate = _adjustValidDate(newDate);
                  });
                  goalSetupState.setStartDate(selectedDate.toIso8601String());
                },
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TargetWeightScreen(),
                    ),
                  );
                },
                child: Row(
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

  /// Hàm kiểm tra và điều chỉnh ngày hợp lệ khi đổi năm
  DateTime _adjustValidDate(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    // Nếu ngày không hợp lệ trong tháng, tự động đổi thành ngày cuối cùng hợp lệ
    int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    return DateTime(year, month, day);
  }
}
