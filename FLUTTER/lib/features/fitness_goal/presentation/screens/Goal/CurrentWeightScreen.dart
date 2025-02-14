import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/CurrentValueScreen.dart';

class CurrentWeightScreen extends StatefulWidget {
  final String goalType;

  CurrentWeightScreen({required this.goalType});

  @override
  _CurrentWeightScreenState createState() => _CurrentWeightScreenState();
}

class _CurrentWeightScreenState extends State<CurrentWeightScreen> {
  final List<int> weightList = List.generate(100, (index) => index + 30);
  int selectedWeight = 64; // Giá trị mặc định

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalSetupState = Provider.of<GoalSetupState>(context, listen: false);
      if (goalSetupState.weight == null) {
        goalSetupState.setWeight(selectedWeight.toDouble());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalSetupState = Provider.of<GoalSetupState>(context);
    selectedWeight = goalSetupState.weight?.toInt() ?? 64;

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
          "Bước 3 trên 15",
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
              "What is your current weight?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We need some data to calculate your BMI and create a plan tailored to you.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 30),

            // Hiển thị cân nặng được chọn
            Center(
              child: Text(
                "$selectedWeight,0 kg",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            // Picker chọn cân nặng
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.black,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: weightList.indexOf(selectedWeight),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedWeight = weightList[index];
                  });
                  goalSetupState.setWeight(weightList[index].toDouble());
                },
                children: weightList.map((weight) {
                  return Center(
                    child: Text(
                      "$weight,0 kg",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  );
                }).toList(),
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
                  goalSetupState.setWeight(selectedWeight.toDouble()); // Đảm bảo lưu trước khi chuyển trang
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CurrentValueScreen(),
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
}
