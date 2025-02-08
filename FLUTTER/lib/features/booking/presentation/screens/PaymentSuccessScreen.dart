import 'package:flutter/material.dart';

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
              onPressed: () => Navigator.pop(context),
              child: Text("Go to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
