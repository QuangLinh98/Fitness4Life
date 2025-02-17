import 'package:flutter/material.dart';

class CreateProgressScreen extends StatefulWidget {
  const CreateProgressScreen({Key? key}) : super(key: key);

  @override
  _CreateProgressScreenState createState() => _CreateProgressScreenState();
}

class _CreateProgressScreenState extends State<CreateProgressScreen> {
  String activity = 'Chạy bộ';
  TextEditingController distanceController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController stepsController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime startTime = DateTime.now();
  String target = 'Không có mục tiêu';

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
            // Dropdown for Activity
            DropdownButtonFormField<String>(
              value: activity,
              decoration: const InputDecoration(
                labelText: 'Metric name',
                border: OutlineInputBorder(),
              ),
              items: ['Chạy bộ', 'Đạp xe', 'Đi bộ', 'Bơi lội']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  activity = newValue!;
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

            // Steps and Time
            TextFormField(
              controller: stepsController,
              decoration: const InputDecoration(
                labelText: 'Value to track',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: stepsController,
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Tracking date (HH:MM:SS)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 32),

            // Save and Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle save functionality
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle cancel functionality
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
