import 'package:fitness4life/core/widgets/CustomDialog.dart';
import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/user/service/PasswordService.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _oldPasswordError;


  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final passwordService = Provider.of<PasswordService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change password",style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFB00020),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFB00020), // Màu nền đỏ
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mật khẩu hiện tại
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction, // Hiển thị lỗi sau khi người dùng tương tác
                  controller: _oldPasswordController,
                  decoration: InputDecoration(
                    labelText: "Old password",
                    errorText: _oldPasswordError,
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your old password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mật khẩu mới
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction, // Hiển thị lỗi sau khi người dùng tương tác
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: "New password",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter new password";
                    }
                    if(value == _oldPasswordController.text) {
                      return "The new password must not be the same as the old password";
                    }
                    if (value.length < 6) {
                      return "The new password must be at least 6 characters long ...";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Xác nhận mật khẩu mới
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction, // Hiển thị lỗi sau khi người dùng tương tác
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: "Confirm password",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.white, // Đặt màu trắng cho lỗi
                      fontSize: 12,        // Cỡ chữ của lỗi
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter confirm new password";
                    }
                    if (value != _newPasswordController.text) {
                      return "New password doesn't match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Nút Xác Nhận
                Center(
                  child: passwordService.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await passwordService.changePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                            _confirmPasswordController.text,
                          );

                          // Nếu không có lỗi, hiển thị dialog thành công
                          CustomDialog.show(
                            context,
                            title: "Success",
                            content: "Change password successfully",
                            buttonText: "OK",
                            onButtonPressed: () {
                              // Điều hướng về trang login
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                          );
                        } catch (e) {
                          // Xử lý lỗi từ backend
                          setState(() {
                            _oldPasswordError = "Old password does not match"; // Hiển thị lỗi từ backend
                          });

                          // Hiển thị thông báo lỗi cho người dùng
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(passwordService.errorMessage ?? "Unknown error occurred"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        // Form không hợp lệ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill out all fields correctly."),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB00020),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
