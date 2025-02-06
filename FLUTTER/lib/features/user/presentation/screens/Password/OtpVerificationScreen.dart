import 'package:fitness4life/features/user/presentation/screens/Login_Register/LoginScreen.dart';
import 'package:fitness4life/features/user/service/PasswordService.dart';
import 'package:fitness4life/features/user/service/RegisterService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String mode; // "resetPassword" hoặc "verifyAccount"

  const OtpVerificationScreen({Key? key, required this.email , required this.mode}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _remainingTime = 300; // 5 phút (300 giây)
  late Timer _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _resendOtp(BuildContext context) async {
    final passwordService = Provider.of<PasswordService>(context, listen: false);
    final registerService = Provider.of<RegisterService>(context, listen: false);

    setState(() {
      _isResending = true;
    });

    try {
      if (widget.mode == "resetPassword") {
        await passwordService.sendOtpPassword(widget.email);
      } else if (widget.mode == "verifyAccount") {
        await registerService.verifyAccount(widget.email);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _remainingTime = 300;
      });
      _startCountdown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordService.errorMessage ?? "Failed to resend OTP"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the 6-digit OTP."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final passwordService = Provider.of<PasswordService>(context, listen: false);
    final registerService = Provider.of<RegisterService>(context, listen: false);

    setState(() {
      _isResending = true; // Dùng chung trạng thái để hiển thị loader khi đang xác thực OTP
    });

    try {
      if(widget.mode == "resetPassword") {
        // Gửi OTP đến API để xác thực
        await passwordService.resetPassword(otp);

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP verified successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển sang màn hình tiếp theo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(), // Hoặc bất kỳ màn hình nào sau xác thực
          ),
        );
      }
      else if (widget.mode == "verifyAccount") {
         await registerService.verifyAccount(otp);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("Account verified successfully!"),
             backgroundColor: Colors.green,
           ),
         );
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (context) => LoginScreen(),
           ),
         );
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu OTP không hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == "resetPassword"
                ? (passwordService.errorMessage ?? "Invalid OTP for reset password!")
                : (registerService.errorMessage ?? "Invalid OTP for account verification!")
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }


  @override
  void dispose() {
    _timer.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordService = Provider.of<PasswordService>(context);

    return Scaffold(
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
      body: Container(
        color: const Color(0xFFB00020),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
               Text(
                widget.mode == "resetPassword"
                     ? "Enter the OTP sent to your email to reset your password"
                     : "Enter the OTP sent to your email to verify your account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _remainingTime > 0
                      ? _verifyOtp
                      : () => _resendOtp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB00020),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(150, 50),
                  ),
                  child: _isResending
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFB00020)),
                  )
                      : Text(
                    _remainingTime > 0
                        ? "Verify ($_formattedTime)"
                        : "Resend OTP",
                    style: const TextStyle(
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
    );
  }
}
