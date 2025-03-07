import 'package:fitness4life/features/Home/presentation/screens/HomeScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/DashboardScreen.dart';
import 'package:fitness4life/features/fitness_goal/presentation/screens/HealthScreen.dart';
import 'package:fitness4life/features/notification/presentation/NotificationScreen2.dart';
import 'package:fitness4life/features/user/presentation/screens/AccountScreen.dart';
import 'package:flutter/material.dart';

import '../../features/notification/presentation/NotificationScreen2.dart';

class PageManager extends StatefulWidget {
  final int initialIndex;
  final int? initialDashboardTabIndex;

  const PageManager({super.key, this.initialIndex = 0, this.initialDashboardTabIndex});

  static _PageManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PageManagerState>();
  }

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  late int _selectedIndex ;
  late List<Widget> _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.initialIndex;

    _pages = [
      HomeScreen(),
      // Tab "Home"
      ClassScreen(),
      // Tab "Classes"
      DashboardScreen(initialTabIndex: widget.initialDashboardTabIndex ?? 0),
      // Tab "Health"
      NotificationScreen2(),
      // Tab "Health"
      AccountScreen(),
      // Tab "Account"
    ];
  }


  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

}
