import 'package:fitness4life/token/app_initializer.dart';
import 'package:fitness4life/config/locator_setup.dart';
import 'package:fitness4life/config/provider_setup.dart';
import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/user/presentation/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //để đảm bảo Flutter đã sẵn sàng làm việc với các plugin native (như flutter_secure_storage).
  setUpLocator(); // Thiết lập các Dependency ở file Locator_setup

  runApp(MultiProvider(
    providers: providers, // Sử dụng danh sách Providers từ file provider_setup.dart
    child: MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: determineInitialRoute(context), // Truyền context vào đây
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Màn hình chờ khi đang xác định route
        }
        final initialRoute = snapshot.data ?? '/login';
        return MaterialApp(
          title: 'Fitness 4 Life',
          theme: ThemeData(primarySwatch: Colors.purple),
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          routes: {
            '/login': (context) => LoginScreen(),
            '/pageManager': (context) => PageManager(),
          },
        );
      },
    );
  }
}

