import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceRegisterScreen extends StatefulWidget {
  // ... (existing code)
  @override
  _FaceRegisterScreenState createState() => _FaceRegisterScreenState();
}

class _FaceRegisterScreenState extends State<FaceRegisterScreen> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isFaceValid = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
      );
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể khởi tạo camera: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Đăng ký Face ID'),
          backgroundColor: const Color(0xFFB00020),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final scale = _controller.value.aspectRatio / deviceRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Đăng ký Face ID'),
        backgroundColor: const Color(0xFFB00020),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                // Overlay cho khuôn mặt
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isFaceValid ? Colors.green : const Color(0xFFB00020),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(150),
                        ),
                        width: 250,
                        height: 300,
                        child: _isFaceValid
                            ? Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 60,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      if (_isFaceValid)
                        const Text(
                          'Đã phát hiện khuôn mặt! Vui lòng giữ nguyên...',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                // Overlay xử lý
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB00020),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Panel hướng dẫn
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                Text(
                  _errorMessage ?? 'Đặt khuôn mặt vào trong khung và đảm bảo đủ ánh sáng',
                  style: TextStyle(
                    color: _errorMessage != null ? Colors.red : Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 