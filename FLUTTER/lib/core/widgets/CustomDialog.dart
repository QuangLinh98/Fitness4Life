import 'dart:convert';

import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> show(
      BuildContext context, {
        required String title,
        required String content,
        required String buttonText,
        VoidCallback? onButtonPressed,
      }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content.isNotEmpty ? content : "An unexpected error occurred."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                if (onButtonPressed != null) {
                  onButtonPressed();
                }
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

}
