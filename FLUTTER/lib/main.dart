import 'package:fitness4life/config/locator_setup.dart';
import 'package:fitness4life/config/provider_setup.dart';
import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  setUpLocator(); // Thiết lập các Dependency ở file Locator_setup
  runApp(MultiProvider(
    providers: providers, // Sử dụng danh sách Providers từ file provider_setup.dart
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness 4 Life',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: PageManager(),
    );
  }
}


