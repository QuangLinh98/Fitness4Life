import 'package:fitness4life/features/Home/presentation/screens/HomeScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/HealthScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/AccountScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LanguageProvider.dart';

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  static _PageManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PageManagerState>();
  }

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Tab "Home"
    ClassScreen(),  // Tab "Classes"
    HealthScreen(),  // Tab "Health"
    AccountScreen(),  // Tab "Account"
  ];

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVietnamese = Provider.of<LanguageProvider>(context).isVietnamese;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFB00020),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          elevation: 0, // Loại bỏ bóng
          backgroundColor: Colors.transparent, // Trong suốt để hiển thị gradient
          selectedItemColor: Colors.white, // Màu của icon và label khi được chọn
          unselectedItemColor: Colors.white.withOpacity(0.6), // Màu khi không được chọn
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Đậm hơn khi được chọn
            fontSize: 18,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal, // Bình thường khi không được chọn
            fontSize: 12,
          ),
          onTap: (index) => updateIndex(index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: isVietnamese ? 'Trang chủ' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center),
              label: isVietnamese ? 'Lớp học' : 'Classes',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.health_and_safety),
              label: isVietnamese ? 'Sức khỏe' : 'Health',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: isVietnamese ? 'Tài khoản' : 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
