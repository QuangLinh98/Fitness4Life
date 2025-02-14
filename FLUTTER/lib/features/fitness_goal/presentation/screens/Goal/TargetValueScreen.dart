import 'package:fitness4life/features/fitness_goal/presentation/screens/Goal/StartDateScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/fitness_goal/data/Goal/GoalSetupState.dart';

class TargetValueScreen extends StatefulWidget {
  @override
  _TargetValueScreenState createState() => _TargetValueScreenState();
}

class _TargetValueScreenState extends State<TargetValueScreen> {
  final List<int> weightList = List.generate(100, (index) => index + 30); // 30kg - 129kg
  final List<int> fatPercentageList = List.generate(51, (index) => index + 10); // 10% - 60%

  int selectedValue = 64; // Giá trị mặc định (kg)
  bool isKgSelected = true; // Mặc định là kg

  @override
  void initState() {
    super.initState();
    final goalSetupState = Provider.of<GoalSetupState>(context, listen: false);
    selectedValue = goalSetupState.targetValue?.toInt() ?? 64;
    isKgSelected = goalSetupState.isKgSelected; // Lấy đơn vị đã lưu trước đó
  }

  @override
  Widget build(BuildContext context) {
    final goalSetupState = Provider.of<GoalSetupState>(context);

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
          "Bước 5 trên 15",
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
              "What is your target value?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            const Text(
              "We need some data to calculate your BMI and create a plan tailored to you.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 30),

            // Chọn giữa kg và %
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnitButton("kg", isKgSelected, goalSetupState),
                SizedBox(width: 10),
                _buildUnitButton("%", !isKgSelected, goalSetupState),
              ],
            ),

            SizedBox(height: 20),

            // Hiển thị giá trị đã chọn
            Center(
              child: Text(
                isKgSelected ? "$selectedValue,0 kg" : "$selectedValue %",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            // Picker chọn giá trị
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.black,
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: isKgSelected
                      ? weightList.indexOf(selectedValue)
                      : fatPercentageList.indexOf(selectedValue),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedValue = isKgSelected
                        ? weightList[index]
                        : fatPercentageList[index];
                  });
                  goalSetupState.setTargetValue(selectedValue.toDouble());
                },
                children: (isKgSelected ? weightList : fatPercentageList)
                    .map((value) {
                  return Center(
                    child: Text(
                      isKgSelected ? "$value,0 kg" : "$value %",
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
                  goalSetupState.setTargetValue(selectedValue.toDouble());
                  goalSetupState.setUnit(isKgSelected); // Lưu đơn vị vào GoalSetupState

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartDateScreen(),
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

  /// **Nút chọn đơn vị kg hoặc %**
  Widget _buildUnitButton(String label, bool isSelected, GoalSetupState goalSetupState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isKgSelected = (label == "kg");
          selectedValue = isKgSelected ? 64 : 20; // Đổi giá trị mặc định khi đổi đơn vị
        });
        goalSetupState.setUnit(isKgSelected); // Lưu đơn vị vào GoalSetupState
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
