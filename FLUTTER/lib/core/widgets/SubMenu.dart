import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/WorkoutPackageScreen.dart';
import 'package:flutter/material.dart';

class SubMenu  extends StatelessWidget {
  const SubMenu ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildMenuButton(Icons.calendar_today, 'Schedule',(){
            PageManager.of(context)?.updateIndex(1);
          }),
          buildMenuButton(Icons.person, 'Trainer',(){}),
          buildMenuButton(Icons.book, 'Class Schedule',(){}),
          buildMenuButton(Icons.credit_card, 'Membership',() {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutPackageScreen()),
            );
          }),
          buildMenuButton(Icons.shopping_cart, 'Services',(){}),
        ],
      ),
    );
  }

  // Tạo nút menu
  Widget buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFB00020).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFFB00020), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

}
