import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:fitness4life/features/user/presentation/screens/Password/OtpVerificationScreen.dart';
import 'package:fitness4life/features/user/service/RegisterService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedGender; // Biến lưu trữ giới tính được chọn
  bool _acceptTerms = false; // Biến theo dõi checkbox
  bool _isLoading = false; // Biến theo dõi trạng thái loading

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //Chuẩn hóa email tránh hack 1 email có thể đăng ký nhiều tài khoản
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  String normalizeEmail(String email) {
    if (!isValidEmail(email)) {
      return email; // Trả về email ban đầu nếu không hợp lệ
    }

    final parts = email.split('@');
    final localPart = parts[0];
    final domainPart = parts[1];
    final normalizedLocal = localPart.split('+')[0].toLowerCase();
    return '$normalizedLocal@$domainPart';
  }


  void _handleRegister() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      _isLoading = true; // Bắt đầu trạng thái loading
    });

    try {
      final registerService =
          Provider.of<RegisterService>(context, listen: false);

      if (_acceptTerms) {
        // Chuẩn hóa email trước khi sử dụng
        final normalizedEmail = normalizeEmail(_emailController.text.trim());
        print("Full Name: ${_fullNameController.text.trim()}");
        print("Email: $normalizedEmail");

        // Gọi service để đăng ký tài khoản với email đã chuẩn hóa
        await registerService.registerAccount(
          _fullNameController.text.trim(),
          normalizedEmail,
          _passwordController.text,
          _confirmPasswordController.text,
          _selectedGender?.toUpperCase() ?? 'OTHER',
        );

        // Nếu thành công, điều hướng tới LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OtpVerificationScreen(email: _emailController.text.trim(), mode: "verifyAccount")),
        );

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must accept the terms and conditions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc trạng thái loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: _formKey,
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

                // Full Name TextField
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your fullname',
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email TextField
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password TextField
                TextFormField(
                  controller: _passwordController,
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
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password TextField
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender Selection
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Male', 'Female']
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Select gender',
                    prefixIcon: const Icon(Icons.transgender, color: Colors.grey),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gender is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Accept Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value!;
                        });
                      },
                      activeColor: Colors.white,
                      checkColor: const Color(0xFFB00020),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Accept the Terms of Service, ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Click here',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Điều hướng đến trang điều khoản
                                print('Navigate to terms of service');
                              }, // Add a gesture recognizer for navigation.
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Register Button with loading spinner
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB00020),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _acceptTerms && !_isLoading ? _handleRegister : null,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFB00020)),
                    ),
                  )
                      : const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Navigation
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'If you already have an account, please ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Log in here',
                          style: const TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginScreen(), // Your LoginScreen widget
                                  ));
                            }, // Add a gesture recognizer for navigation.
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
