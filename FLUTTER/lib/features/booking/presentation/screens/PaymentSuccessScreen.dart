import 'package:fitness4life/features/Home/presentation/screens/HomeScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/bottom_navigation_bar.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Successful")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            const Text("Payment Successful!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Truy cập `PageManager` và chuyển sang tab thứ 2 (index = 1)
                PageManager.of(context)?.updateIndex(1);

                // Quay lại `PageManager`
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
