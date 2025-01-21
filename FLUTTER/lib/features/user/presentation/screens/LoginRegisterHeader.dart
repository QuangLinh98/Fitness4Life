import 'package:fitness4life/features/user/presentation/screens/LoginScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/RegisterScreen.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginRegisterHeader extends StatelessWidget {
  const LoginRegisterHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<UserInfoProvider>(context).userName;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header nền đỏ
        Container(
          height: 150,
          color: const Color(0xFFB00020),
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Center(
            child: Text(
              userName != null ? 'Xin chào, $userName!' : 'Xin chào quý khách hàng !',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Các nút Đăng Nhập và Đăng Ký
        Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút Đăng Nhập
                buildLoginRegisterButton(Icons.login_rounded, 'LOGIN', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  LoginScreen()),
                  );
                }),

                // Nút Đăng Ký
                buildLoginRegisterButton(Icons.assignment, 'REGISTER', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Hàm tạo nút Đăng Nhập và Đăng Ký
  Widget buildLoginRegisterButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB00020), width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: const Color(0xFFB00020),
            ),
            iconSize: 36,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB00020),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}