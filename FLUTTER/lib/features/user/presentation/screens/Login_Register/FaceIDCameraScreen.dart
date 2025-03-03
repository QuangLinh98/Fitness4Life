import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/user/service/UserInfoProvider.dart';
import 'package:fitness4life/features/user/service/FaceValidation.dart';

class FaceIDCameraScreen extends StatefulWidget {
  const FaceIDCameraScreen({Key? key}) : super(key: key);

  @override
  State<FaceIDCameraScreen> createState() => _FaceIDCameraScreenState();
}

class _FaceIDCameraScreenState extends State<FaceIDCameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isFaceValid = false;
  bool _isLowLight = false;
  bool _hasFace = false;
  bool _isDebugMode = false;
  String _debugInfo = '';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
        _startImageProcessing();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể khởi tạo camera. Vui lòng kiểm tra quyền truy cập camera.';
        });
      }
    }
  }

  void _startImageProcessing() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((image) {
      if (!_isProcessing) {
        _analyzeImage(image);
      }
    });
  }

  void _stopImageProcessing() {
    _controller?.stopImageStream();
  }

  Future<void> _analyzeImage(CameraImage image) async {
    if (_isProcessing) return;

    try {
      // Tính độ sáng trung bình của khung hình
      final bytes = image.planes[0].bytes;
      int totalBrightness = 0;
      for (int i = 0; i < bytes.length; i += 20) {
        totalBrightness += bytes[i];
      }
      double avgBrightness = totalBrightness / (bytes.length / 20);

      // Kiểm tra điều kiện ánh sáng
      bool isLowLight = avgBrightness < 70;

      // Phân tích để phát hiện khuôn mặt
      int width = image.width;
      int height = image.height;
      int changes = 0;

      // Quét toàn bộ khung hình
      for (int y = 0; y < height; y += 10) {
        for (int x = 0; x < width; x += 10) {
          if (x + 10 < width) {
            int pos1 = y * width + x;
            int pos2 = y * width + (x + 10);

            if (pos2 < width * height && (bytes[pos1] - bytes[pos2]).abs() > 20) {
              changes++;
            }
          }
        }
      }

      // Cập nhật thông tin debug
      if (_isDebugMode) {
        setState(() {
          _debugInfo = 'Độ sáng: ${avgBrightness.toStringAsFixed(1)}\n'
              'Thay đổi: $changes';
        });
      }

      // Phát hiện khuôn mặt và tiến hành đăng nhập
      bool detectedFace = changes > 100;

      setState(() {
        _isLowLight = isLowLight;
        _hasFace = detectedFace;
      });

      if (detectedFace && !isLowLight && !_isProcessing) {
        _stopImageProcessing();
        await _captureAndLogin();
      }

    } catch (e) {
      print('Lỗi phân tích hình ảnh: $e');
    }
  }

  Future<void> _captureAndLogin() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _controller?.takePicture();
      if (image == null) throw Exception("Không thể chụp ảnh");

      final File imageFile = File(image.path);
      if (!imageFile.existsSync()) throw Exception("Không tìm thấy file ảnh");

      // Xác thực khuôn mặt
      final validationResult = await FaceValidator.validateFace(imageFile);

      setState(() {
        _isFaceValid = validationResult.isValid;
        _imageFile = imageFile;

        if (!validationResult.isValid) {
          _errorMessage = validationResult.message ?? "Không thể nhận diện khuôn mặt";
          _isProcessing = false;
          _startImageProcessing();
          return;
        }
      });

      // Tiến hành đăng nhập
      final loginService = Provider.of<LoginService>(context, listen: false);
      try {
        await loginService.loginByFaceId(imageFile);
      } catch (e) {
        throw Exception("Khuôn mặt không khớp với dữ liệu trong hệ thống");
      }

      if (mounted) {
        if (loginService.loggedInUser != null) {
          Provider.of<UserInfoProvider>(context, listen: false)
              .setUserName(loginService.loggedInUser!.fullname ?? "Khách");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PageManager()),
          );
        } else if (loginService.errorMessage != null) {
          setState(() {
            _errorMessage = loginService.errorMessage;
          });
          _startImageProcessing();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception:", "").trim();
        });
        _startImageProcessing();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopImageProcessing();
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopImageProcessing();
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Face ID Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFB00020),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFB00020),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Face ID Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB00020),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDebugMode ? Icons.bug_report : Icons.bug_report_outlined,
              color: _isDebugMode ? Colors.white : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _isDebugMode = !_isDebugMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB00020), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _imageFile != null
                      ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  )
                      : _isInitialized
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      // Camera Preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CameraPreview(_controller!),
                      ),

                      // Overlay tối để làm nổi bật khuôn mặt
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Hướng dẫn với nền trong suốt gradient
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _isLowLight
                                ? 'Ánh sáng quá yếu, vui lòng tìm nơi sáng hơn'
                                : (_hasFace
                                ? 'Đã phát hiện khuôn mặt, đang xử lý...'
                                : 'Đưa khuôn mặt vào khung hình'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isLowLight
                                  ? Colors.orange
                                  : (_hasFace ? Colors.green : Colors.white),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Cảnh báo ánh sáng yếu
                      if (_isLowLight && !_isDebugMode)
                        Positioned(
                          top: 30,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.9),
                                  Colors.orange.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wb_sunny, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Ánh sáng quá yếu, vui lòng tìm nơi sáng hơn',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Debug info
                      if (_isDebugMode)
                        Positioned(
                          top: 30,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _debugInfo,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                      : const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB00020),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
            // Panel hướng dẫn
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _errorMessage ?? 'Giữ khuôn mặt trong khung hình và đảm bảo đủ ánh sáng',
                    style: TextStyle(
                      color: _errorMessage != null ? Colors.red : Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}