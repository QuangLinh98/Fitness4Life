import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/booking/presentation/screens/ClassesScreen.dart';
import 'package:fitness4life/features/booking/presentation/screens/WorkoutPackageScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LanguageProvider.dart';

class SubMenu  extends StatelessWidget {
  const SubMenu ({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildMenuButton(Icons.calendar_today, Provider.of<LanguageProvider>(context).isVietnamese ? 'Lịch' : 'Schedule', (){
            PageManager.of(context)?.updateIndex(1);
          }),
          buildMenuButton(Icons.person, Provider.of<LanguageProvider>(context).isVietnamese ? 'Huấn luyện viên' : 'Trainer', () {}),
          buildMenuButton(Icons.book, Provider.of<LanguageProvider>(context).isVietnamese ? 'Lịch lớp' : 'Class Schedule', () {}),
          buildMenuButton(Icons.credit_card, Provider.of<LanguageProvider>(context).isVietnamese ? 'Gói thành viên' : 'Membership', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkoutPackageScreen()),
            );
          }),
          buildMenuButton(Icons.shopping_cart, Provider.of<LanguageProvider>(context).isVietnamese ? 'Dịch vụ' : 'Services', () {}),
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
