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

  // Add a debounce timer to prevent multiple rapid face detections
  Timer? _debounceTimer;
  // Add a cooldown flag to prevent rapid consecutive API calls
  bool _isInCooldown = false;
  // Add a throttle timestamp to limit face detection frequency
  int _lastProcessTimestamp = 0;

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
          _errorMessage = 'Unable to initialize camera. Please check camera permissions.';
        });
      }
    }
  }

  void _startImageProcessing() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((image) {
      // Only process frames at a reasonable rate (at most once every 500ms)
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - _lastProcessTimestamp < 500) return;

      if (!_isProcessing && !_isInCooldown) {
        _lastProcessTimestamp = currentTime;
        _analyzeImage(image);
      }
    });
  }

  void _stopImageProcessing() {
    _controller?.stopImageStream();
    _debounceTimer?.cancel();
  }

  Future<void> _analyzeImage(CameraImage image) async {
    if (_isProcessing || _isInCooldown) return;

    try {
      // Cancel any existing debounce timer
      _debounceTimer?.cancel();

      // Improved face detection with better thresholds and sampling
      int changes = 0;
      final bytes = image.planes[0].bytes;
      int width = image.width;
      int height = image.height;

      // Optimize scanning pattern - sample more efficiently
      for (int y = height ~/ 4; y < 3 * height ~/ 4; y += 10) {
        for (int x = width ~/ 4; x < 3 * width ~/ 4; x += 10) {
          if (x + 10 < width) {
            int pos1 = y * width + x;
            int pos2 = y * width + (x + 10);

            if (pos2 < width * height && (bytes[pos1] - bytes[pos2]).abs() > 30) {
              changes++;
            }
          }
        }
      }

      // Calculate brightness to detect low light conditions
      int brightness = 0;
      int samples = 0;
      for (int y = 0; y < height; y += 20) {
        for (int x = 0; x < width; x += 20) {
          int pos = y * width + x;
          if (pos < width * height) {
            brightness += bytes[pos];
            samples++;
          }
        }
      }

      int avgBrightness = samples > 0 ? brightness ~/ samples : 0;
      bool isLowLight = avgBrightness < 70; // Threshold for low light detection

      // Adaptive face detection threshold based on lighting conditions
      bool detectedFace = changes > (isLowLight ? 120 : 150);

      // Update debug info
      _debugInfo = 'Changes: $changes\nBrightness: $avgBrightness\nFace: $detectedFace';

      if (mounted) {
        setState(() {
          _hasFace = detectedFace;
          _isLowLight = isLowLight;
        });
      }

      // Debounce face detection to prevent multiple triggers
      if (detectedFace && !_isLowLight && !_isProcessing && !_isInCooldown) {
        // Set cooldown to prevent multiple rapid captures
        _isInCooldown = true;

        // Use a debounce timer to wait a moment before capturing
        _debounceTimer = Timer(const Duration(milliseconds: 800), () {
          if (_hasFace && !_isProcessing && mounted) {
            _stopImageProcessing();
            _captureAndLogin();
          }
        });
      }

    } catch (e) {
      print('Image analysis error: $e');
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
      if (image == null) throw Exception("Cannot take photos");

      final File imageFile = File(image.path);
      if (!imageFile.existsSync()) throw Exception("Image file not found");

      setState(() {
        _imageFile = imageFile;
      });

      // Validate face before proceeding with login
      final validationResult = await FaceValidator.validateFace(imageFile);

      if (!validationResult.isValid) {
        setState(() {
          _isFaceValid = false;
          _errorMessage = validationResult.message ?? "Face not recognized";
          _isProcessing = false;
        });

        // Add a delay before restarting camera to prevent rapid retries
        await Future.delayed(const Duration(seconds: 1));
        _imageFile = null;
        _startImageProcessing();
        return;
      }

      setState(() {
        _isFaceValid = true;
      });

      // Proceed with login
      final loginService = Provider.of<LoginService>(context, listen: false);
      try {
        await loginService.loginByFaceId(imageFile);
      } catch (e) {
        throw Exception("Face authentication failed: ${e.toString()}");
      }

      if (mounted) {
        if (loginService.loggedInUser != null) {
          Provider.of<UserInfoProvider>(context, listen: false)
              .setUserName(loginService.loggedInUser!.fullname ?? "Guest");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PageManager()),
          );
        } else if (loginService.errorMessage != null) {
          setState(() {
            _errorMessage = loginService.errorMessage;
          });

          await Future.delayed(const Duration(seconds: 1));
          _imageFile = null;
          _startImageProcessing();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception:", "").trim();
        });

        await Future.delayed(const Duration(seconds: 1));
        _imageFile = null;
        _startImageProcessing();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          // Reset cooldown after a short delay to prevent immediate retries
          Future.delayed(const Duration(seconds: 2), () {
            _isInCooldown = false;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopImageProcessing();
    _controller?.dispose();
    _debounceTimer?.cancel();
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
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                      // Add loading spinner when processing image
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Verifying face...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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

                      // Overlay to highlight face
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Face outline indicator that changes color when face detected
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _hasFace ? Colors.green : Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),

                      // Loading indicator when face is detected but before capture
                      if (_hasFace && !_isProcessing && _debounceTimer != null && _debounceTimer!.isActive)
                        Center(
                          child: Container(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 3,
                            ),
                          ),
                        ),

                      // Guidance with transparent gradient background
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
                                ? 'The light is too weak, please find a brighter place.'
                                : (_hasFace
                                ? 'Face detected, please hold still...'
                                : 'Position your face in the circle'),
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

                      // Low light warning
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
                                    'The light is too weak, please find a brighter place.',
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
            // Guidance panel
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
                    _errorMessage ?? 'Keep your face in the frame and make sure there is enough light',
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