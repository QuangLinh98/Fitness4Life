import 'package:fitness4life/features/Home/presentation/screens/HomeScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:flutter/material.dart';

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(), // Tab "Home"
    ClassScreen(),  // Tab "Classes"
    // AccountPage(),  // Tab "Account"
  ];

  void _onTabSelected(int index) {
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
          onTap: _onTabSelected,
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
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

}
