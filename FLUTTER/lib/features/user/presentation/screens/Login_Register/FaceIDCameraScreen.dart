import 'dart:async';
import 'dart:io';
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
      if (image == null) throw Exception("Failed to capture image");

      final File imageFile = File(image.path);
      if (!imageFile.existsSync()) throw Exception("Image file not found");

      // Validate face first
      final validationResult = await FaceValidator.validateFace(imageFile);
      
      setState(() {
        _isFaceValid = validationResult.isValid;
        if (!validationResult.isValid) {
          _errorMessage = validationResult.message;
          _isProcessing = false;
          return;
        }
      });

      // Proceed with login if validation passed
      final loginService = Provider.of<LoginService>(context, listen: false);
      await loginService.loginByFaceId(imageFile);

      // Check results
      if (mounted) {
        if (loginService.loggedInUser != null) {
          // Stop auto-login timer on success
          _autoLoginTimer?.cancel();

          // Success case
          Provider.of<UserInfoProvider>(context, listen: false)
              .setUserName(loginService.loggedInUser!.fullname ?? "Guest");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PageManager()),
          );
        } else if (loginService.errorMessage != null) {
          // Error case from LoginService
          setState(() {
            _errorMessage = loginService.errorMessage;
          });

          // Show error in SnackBar for better visibility
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginService.errorMessage!),
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

        // Show error in SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? "An error occurred"),
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
                  Transform.rotate(
                    angle: -3.14159 / 2,
                    child: Transform.scale(
                      scale: 2.0,
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isFaceValid ? Colors.green : const Color(0xFFB00020),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  width: 200,
                  height: 300,
                ),
              ],
            ),
          ),
          // Error message display
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.1),
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                // Instruction text
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Automatically scanning face. Position inside the circle with good lighting.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Progress indicator
                if (_isProcessing)
                  const CircularProgressIndicator(
                    color: Color(0xFFB00020),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}