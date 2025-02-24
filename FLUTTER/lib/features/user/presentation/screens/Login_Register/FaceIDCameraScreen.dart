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
  Timer? _autoLoginTimer;
  bool _isFaceValid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    // Lock to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      // Use the front camera for face ID
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });

        // Start auto-login timer after camera is initialized
        _startAutoLoginTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not initialize camera. Please check camera permissions.';
        });
      }
    }
  }

  void _startAutoLoginTimer() {
    _autoLoginTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isProcessing && _isInitialized) {
        _captureAndLogin();
      }
    });
  }

  Future<void> _captureAndLogin() async {
    if (_isProcessing || !_isInitialized) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _controller?.takePicture();
      if (image == null) throw Exception("Unable to take photos");

      final File imageFile = File(image.path);
      if (!imageFile.existsSync()) throw Exception("No image file found.");

      // Validate face first
      final validationResult = await FaceValidator.validateFace(imageFile);
      
      setState(() {
        _isFaceValid = validationResult.isValid;
        if (!validationResult.isValid) {
          _errorMessage = validationResult.message ?? "Unable to recognize faces";
          _isProcessing = false;
          return;
        }
      });

      // Proceed with login if validation passed
      final loginService = Provider.of<LoginService>(context, listen: false);
      try {
        await loginService.loginByFaceId(imageFile);
      } catch (e) {
        throw Exception("Faces don't match the data in the system.");
      }

      // Check results
      if (mounted) {
        if (loginService.loggedInUser != null) {
          _autoLoginTimer?.cancel();
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? "An error has occurred"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception:", "").trim();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? "An error has occurred"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
    _autoLoginTimer?.cancel();
    _controller?.dispose();
    // Reset orientation
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
          title: const Text('Face ID Login'),
          backgroundColor: const Color(0xFFB00020),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
        title: const Text('Face ID Login'),
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
                if (_controller != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Transform.scale(
                        scale: 1,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(Platform.isAndroid ? pi : 0),
                          child: SizedBox(
                            width: _controller!.value.previewSize?.width ?? 0,
                            height: _controller!.value.previewSize?.height ?? 0,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Updated face detection overlay
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
                          'Face Detection! Please hold still....',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                // Processing overlay
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

          // Bottom instruction panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                Text(
                  _errorMessage ?? 'Position your face within the circle and ensure good lighting',
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