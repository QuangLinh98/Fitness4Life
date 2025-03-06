import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fitness4life/features/user/service/LoginService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fitness4life/core/widgets/bottom_navigation_bar.dart';
import 'package:fitness4life/features/user/service/RegisterService.dart';

import '../../../../../token/token_manager.dart';
import '../../../data/models/User.dart';
import '../../../service/FaceValidation.dart';

class FaceIDRegisterScreen extends StatefulWidget {
  final int userId;
  final String email;
  final String password;
  final String? accessToken; // Thêm token như một tham số tùy chọn

  const FaceIDRegisterScreen({
    Key? key,
    required this.userId,
    required this.email,
    required this.password,
    this.accessToken, // Optional token
  }) : super(key: key);

  @override
  State<FaceIDRegisterScreen> createState() => _FaceIDRegisterScreenState();
}

class _FaceIDRegisterScreenState extends State<FaceIDRegisterScreen> {
  File? _imageFile;
  String _validationMessage = '';
  bool _isValid = false;
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isTestMode = true; // Default to test mode
  bool _isDebugMode = false;  // Debug mode variable
  String _debugInfo = '';     // Debug information
  bool _isLowLight = false;  // Low light detection variable

  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isFaceDetected = false;
  int _faceDetectionCount = 0;
  Timer? _faceDetectionTimer;
  bool _isFaceCentered = false; // Variable to check if face is centered

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _faceDetectionTimer?.cancel();
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isProcessing = true;
      _validationMessage = 'Initializing camera...';
    });

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController.initialize();

      // Chỉ bắt đầu nhận diện khuôn mặt tự động nếu không ở chế độ thử nghiệm
      if (!_isTestMode) {
        _startFaceDetection();
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isProcessing = false;
          _validationMessage = _isTestMode
              ? 'Manual mode: Click "Take Photo" to continue'
              : 'Put your face in the frame';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _validationMessage = 'Camera initialization error: $e';
      });
    }
  }

  void _startFaceDetection() {
    // Start face detection
    _cameraController.startImageStream((image) {
      if (!_isProcessing && !_isFaceDetected) {
        _detectFace(image);
      }
    });
  }

  void _stopFaceDetection() {
    if (_cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
  }

  // Chuyển đổi giữa chế độ thử nghiệm và chế độ tự động
  void _toggleTestMode() {
    setState(() {
      _isTestMode = !_isTestMode;
      _validationMessage = _isTestMode
          ? 'Manual mode: Click "Take Photo" to continue'
          : 'Automatic mode: Put your face in the frame';
      
      // Đặt lại các biến trạng thái khi chuyển chế độ
      _isFaceDetected = false;
      _faceDetectionCount = 0;
      _isFaceCentered = false;
    });

    if (_isTestMode) {
      _stopFaceDetection();
    } else {
      _startFaceDetection();
    }
  }

  void _toggleDebugMode() {
    setState(() {
      _isDebugMode = !_isDebugMode;
    });
  }

  Future<void> _detectFace(CameraImage image) async {
    try {
      // Phương pháp đơn giản - chỉ kiểm tra sự thay đổi giữa các khung hình
      final bytes = image.planes[0].bytes;
      
      // Tính độ sáng trung bình của toàn bộ hình ảnh
      int totalBrightness = 0;
      for (int i = 0; i < bytes.length; i += 20) {  // Lấy mẫu để cải thiện hiệu suất
        totalBrightness += bytes[i];
      }
      double avgBrightness = totalBrightness / (bytes.length / 20);
      
      // Kiểm tra điều kiện ánh sáng
      bool isLowLight = avgBrightness < 70;  // Ngưỡng ánh sáng thấp
      
      // Lấy mẫu một số điểm ảnh từ vùng trung tâm
      int width = image.width;
      int height = image.height;
      int centerX = width ~/ 2;
      int centerY = height ~/ 2;
      int sampleSize = 50;  // Kích thước mẫu
      
      // Kiểm tra sự thay đổi giữa các điểm ảnh liền kề
      int changes = 0;
      for (int y = centerY - sampleSize; y < centerY + sampleSize; y += 5) {
        for (int x = centerX - sampleSize; x < centerX + sampleSize; x += 5) {
          if (y >= 0 && y < height && x >= 0 && x < width) {
            int pos1 = y * width + x;
            int pos2 = y * width + (x + 5);
            
            if (pos2 < width * height && (bytes[pos1] - bytes[pos2]).abs() > 20) {
              changes++;
            }
          }
        }
      }
      
      // Nếu có nhiều thay đổi, có thể có khuôn mặt
      bool hasFace = changes > 80;
      bool isCentered = hasFace;  // Giả sử nếu có khuôn mặt, nó đã được căn giữa
      
      if (_isDebugMode) {
        setState(() {
          _debugInfo = 'Brightness: ${avgBrightness.toStringAsFixed(1)}\n'
                      'Change: $changes\n'
                      'Have a Face: $hasFace\n'
                      'Low light: $isLowLight';
        });
      }
      
      setState(() {
        _isFaceCentered = isCentered;
        _isLowLight = isLowLight;
      });

      // Nếu ánh sáng quá yếu, hiển thị thông báo
      if (isLowLight) {
        setState(() {
          _validationMessage = 'The light is too weak, please find a brighter place.';
        });
        return;  // Không tiếp tục xử lý nếu ánh sáng quá yếu
      }

      // Nếu có khuôn mặt và nó được căn giữa
      if (hasFace && isCentered) {
        _faceDetectionCount++;
        
        // Cập nhật thông báo
        if (_faceDetectionCount >= 7 && _faceDetectionCount < 10) {
          setState(() {
            _validationMessage = 'Stay still...';
          });
        }

        // Nếu khuôn mặt được phát hiện liên tục trong 10 khung hình
        if (_faceDetectionCount >= 10) {
          setState(() {
            _isFaceDetected = true;
            _validationMessage = 'Face detected in center! Hold still....';
          });

          // Dừng luồng để chụp ảnh
          await _cameraController.stopImageStream();

          // Đợi một chút để ổn định
          await Future.delayed(const Duration(milliseconds: 500));

          // Chụp ảnh
          await _takePhoto();
        }
      } else {
        _faceDetectionCount = 0;
        if (hasFace && !isCentered) {
          setState(() {
            _validationMessage = 'Move your face to the center of the circle';
          });
        } else if (!hasFace) {
          setState(() {
            _validationMessage = 'Faces are not detected';
          });
        }
      }
    } catch (e) {
      print('Face detection error: $e');
    }
  }

  // Chụp ảnh thủ công (cho chế độ thử nghiệm)
  Future<void> _manualTakePhoto() async {
    if (_isProcessing) return;
    
    // Kiểm tra xem khuôn mặt có được căn giữa không (chỉ khi không ở chế độ thử nghiệm)
    if (!_isTestMode && !_isFaceCentered) {
      setState(() {
        _validationMessage = 'Please place your face in the center of the circle';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _validationMessage = 'Taking pictures...';
    });

    try {
      final XFile photo = await _cameraController.takePicture();
      final imageFile = File(photo.path);

      // Xác thực khuôn mặt
      final validationResult = await FaceValidator.validateFace(imageFile);

      setState(() {
        _imageFile = imageFile;
        _validationMessage = validationResult.message;
        _isValid = validationResult.isValid;
        _isProcessing = false;
      });

      // Nếu khuôn mặt hợp lệ và không ở chế độ thử nghiệm, tự động đăng ký sau 2 giây
      if (_isValid && !_isTestMode) {
        _faceDetectionTimer = Timer(const Duration(seconds: 2), () {
          _registerFace();
        });
      } else if (!_isValid && !_isTestMode) {
        // Nếu không hợp lệ và không ở chế độ thử nghiệm, khởi động lại camera sau 3 giây
        _faceDetectionTimer = Timer(const Duration(seconds: 5), () {
          _resetCamera();
        });
      }
    } catch (e) {
      setState(() {
        _validationMessage = 'Error: $e';
        _isProcessing = false;
      });

      // Khởi động lại camera sau khi gặp lỗi (chỉ ở chế độ tự động)
      if (!_isTestMode) {
        _faceDetectionTimer = Timer(const Duration(seconds: 3), () {
          _resetCamera();
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isProcessing = true;
      _validationMessage = 'Taking pictures...';
    });

    try {
      final XFile photo = await _cameraController.takePicture();
      final imageFile = File(photo.path);

      // Validate face
      final validationResult = await FaceValidator.validateFace(imageFile);

      setState(() {
        _imageFile = imageFile;
        _validationMessage = validationResult.message;
        _isValid = validationResult.isValid;
        _isProcessing = false;
      });

      // If face is valid and not in test mode, automatically register after 2 seconds
      if (_isValid && !_isTestMode) {
        _faceDetectionTimer = Timer(const Duration(seconds: 2), () {
          _registerFace();
        });
      } else if (!_isValid && !_isTestMode) {
        // If not valid and not in test mode, restart camera after 3 seconds
        _faceDetectionTimer = Timer(const Duration(seconds: 3), () {
          _resetCamera();
        });
      }
    } catch (e) {
      setState(() {
        _validationMessage = 'Error: $e';
        _isProcessing = false;
      });

      // Restart camera after error (only in auto mode)
      if (!_isTestMode) {
        _faceDetectionTimer = Timer(const Duration(seconds: 3), () {
          _resetCamera();
        });
      }
    }
  }

  Future<void> _resetCamera() async {
    if (_isCameraInitialized) {
      await _cameraController.dispose();
    }

    setState(() {
      _isCameraInitialized = false;
      _isFaceDetected = false;
      _faceDetectionCount = 0;
      _imageFile = null;
    });

    _initializeCamera();
  }

  Future<void> _registerFace() async {
    if (_imageFile == null || !_isValid) return;

    setState(() {
      _isLoading = true;
      _validationMessage = 'Registering face...';
    });

    try {
      final registerService = Provider.of<RegisterService>(context, listen: false);
      final loginService = Provider.of<LoginService>(context, listen: false);

      String? token = widget.accessToken;
      
      // Nếu không có token được truyền vào, thực hiện đăng nhập để lấy token
      if (token == null) {
        await loginService.login(widget.email, widget.password);
        token = await TokenManager.getAccessToken();
      }

      // Kiểm tra lại token
      if (token == null) {
        throw Exception("Could not get authentication token");
      }

      final response = await registerService.registerFace(_imageFile!, widget.userId, token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Face registration successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PageManager()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              e.toString().contains('already registered')
                  ? 'This face is already registered to another account'
                  : 'Face registration failed: $e'
          ),
          backgroundColor: Colors.red,
        ),
      );

      if (!_isTestMode) {
        _faceDetectionTimer = Timer(const Duration(seconds: 3), () {
          _resetCamera();
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Face ID'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PageManager()),
                  (route) => false,
            );
          },
        ),
        actions: [
          // Nút chuyển đổi giữa chế độ thử nghiệm và tự động
          IconButton(
            icon: Icon(_isTestMode ? Icons.auto_awesome : Icons.science),
              tooltip: _isTestMode ? 'Switch to automatic mode' : 'Switch to manual mode',
            onPressed: _toggleTestMode,
          ),
          // Nút gỡ lỗi
          IconButton(
            icon: Icon(_isDebugMode ? Icons.bug_report : Icons.bug_report_outlined),
            tooltip: _isDebugMode ? 'Turn off debug mode' : 'Enable debug mode',
            onPressed: _toggleDebugMode,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isTestMode ? Icons.science : Icons.auto_awesome,
                  color: const Color(0xFFB00020),
                ),
                const SizedBox(width: 8),
                Text(
                  _isTestMode ? 'Amanual Mode' : 'Automatic Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB00020),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Register your face for quick, secure portal authentication and login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imageFile != null
                      ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  )
                      : _isCameraInitialized
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_cameraController),
                      // Khung hướng dẫn - giảm xuống còn 250x250 để gần hơn
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isLowLight 
                                ? Colors.orange 
                                : (_isFaceCentered ? Colors.green : Colors.white), 
                              width: 2
                            ),
                            borderRadius: BorderRadius.circular(125),
                          ),
                        ),
                      ),
                      // Thêm hướng dẫn
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Text(
                          !_isTestMode 
                            ? (_isLowLight 
                                ? 'The light is too weak, please find a brighter place.'
                                : (_isFaceCentered 
                                    ? 'Face is centered, keep still'
                                    : 'Place your face in the center of the circle'))
                            : '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isLowLight 
                              ? Colors.orange 
                              : (_isFaceCentered ? Colors.green : Colors.white),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                      // Hiển thị cảnh báo ánh sáng yếu
                      if (_isLowLight && !_isDebugMode)
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wb_sunny, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'The light is too weak, please find a brighter place.',
                                    style: TextStyle(
                                      color: Colors.orange,
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
                      // Hiển thị thông tin gỡ lỗi
                      if (_isDebugMode)
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color: Colors.black54,
                            child: Text(
                              _debugInfo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                      : const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB00020),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _validationMessage,
              style: TextStyle(
                color: _isLowLight 
                  ? Colors.orange 
                  : (_isValid ? Colors.green : (_isFaceCentered ? Colors.green : Colors.red)),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Hiển thị nút chụp ở cả hai chế độ
            if (_isCameraInitialized && _imageFile == null)
              ElevatedButton(
                onPressed: _isProcessing ? null : _manualTakePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        _isTestMode ? 'Take a photo' : 'Manual shooting',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Nút thử lại
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isProcessing || !_isCameraInitialized || _imageFile == null) ? null : _resetCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                    )
                        : const Text('Agian',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                // Nút đăng ký
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_imageFile != null && _isValid && !_isLoading)
                        ? _registerFace
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB00020),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text('Register for Face ID',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}