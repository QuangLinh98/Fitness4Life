import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/RegisterScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/Password/ForgotPasswordScreen.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

   LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService  = Provider.of<LoginService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFB00020),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB00020),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Center(
                child: Text(
                  'FITNESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Username TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remember Me and Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Colors.white,
                        checkColor: const Color(0xFFB00020),
                      ),
                      const Text(
                        'Remember password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen())
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Accept Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    activeColor: Colors.white,
                    checkColor: const Color(0xFFB00020),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Acceptance of Terms and Services ..., ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'click me',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: null, // Add a gesture recognizer for navigation.
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB00020),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: loginService.isLoading ? null :  () async {
                  //Gọi LoginService để xử lý login
                  await loginService.login(
                      emailController.text,
                      passwordController.text
                  );
                  // print("Email: ${emailController.text}");
                  // print("Password: ${passwordController.text}");


                  //Xử lý khi login thành công
                  if(loginService.loggedInUser != null) {
                    // print("User Fullname: ${loginService.loggedInUser!.fullname}");

                    // Cập nhật fullname vào UserInfoProvider
                    Provider.of<UserInfoProvider>(context, listen: false)
                        .setUserName(loginService.loggedInUser!.fullname ?? "Guest");

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PageManager()));
                  }
                  else if (loginService.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          loginService.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Navigation
              Center(
                child: TextButton(
                  onPressed: () {
                    // Chuyển hướng đến trang đăng ký
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()), // Đổi thành màn hình bạn muốn
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Xóa khoảng cách mặc định
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "If you don't have an account, please register ",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        TextSpan(
                          text: 'Here',
                          style: TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      )

    );
  }
}
