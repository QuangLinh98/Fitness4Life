import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/ActivityLevelScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:intl/intl.dart';

class EndDateScreen extends StatefulWidget {
  @override
  _EndDateScreenState createState() => _EndDateScreenState();
}

class _EndDateScreenState extends State<EndDateScreen> {
  late DateTime selectedDate; // Khai báo selectedDate

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1); // Ngày mai lúc 00:00:00

    // Đảm bảo selectedDate luôn >= minimumDate (ngày mai)
    selectedDate = tomorrow;
  }

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
          "Bước 7 trên 15",
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
              "When is your end date?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            const Text(
              "We need to know your end date to plan accurately.",
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
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate, // Đảm bảo giá trị hợp lệ
                  minimumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1), // Ngày mai lúc 00:00:00
                  maximumDate: DateTime(2030, 12, 31),
                  backgroundColor: Colors.black,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                    goalSetupState.setEndDate(newDate.toIso8601String());
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
                  // Kiểm tra nếu ngày kết thúc phải lớn hơn hôm nay
                  if (selectedDate.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("End date must be in the future."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityLevelScreen(),
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
}
