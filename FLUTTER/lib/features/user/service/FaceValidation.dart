import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceValidationResult {
  final bool isValid;
  final String message;
  final double? faceSize;
  final double? angle;

  FaceValidationResult({
    required this.isValid,
    required this.message,
    this.faceSize,
    this.angle,
  });
}

class FaceValidator {
  // Constants for face validation
  static const double MIN_FACE_SIZE = 180.0;
  static const double MAX_FACE_SIZE = 280.0;
  static const double MAX_ANGLE = 15.0;

  static Future<FaceValidationResult> validateFace(File imageFile) async {
    final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableTracking: true,
      ),
    );

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      
      await faceDetector.close();

      if (faces.isEmpty) {
        return FaceValidationResult(
          isValid: false,
          message: 'Không tìm thấy khuôn mặt trong ảnh',
          faceSize: 0,
        );
      }

      if (faces.length > 1) {
        return FaceValidationResult(
          isValid: false,
          message: 'Phát hiện nhiều khuôn mặt trong ảnh',
          faceSize: 0,
        );
      }

      final Face face = faces.first;
      final double faceSize = face.boundingBox.width;
      final double? angle = face.headEulerAngleY;



      // if (faceSize > MAX_FACE_SIZE) {
      //   return FaceValidationResult(
      //     isValid: false,
      //     message: 'Vui lòng di chuyển xa hơn',
      //     faceSize: faceSize,
      //     angle: angle,
      //   );
      // }

      if (angle != null && angle.abs() > MAX_ANGLE) {
        return FaceValidationResult(
          isValid: false,
          message: 'Vui lòng giữ khuôn mặt thẳng với camera',
          faceSize: faceSize,
          angle: angle,
        );
      }

      return FaceValidationResult(
        isValid: true,
        message: 'Xác thực khuôn mặt thành công',
        faceSize: faceSize,
        angle: angle,
      );
    } catch (e) {
      await faceDetector.close();
      print('Face detection error: $e');
      return FaceValidationResult(
        isValid: false,
        message: 'Lỗi xử lý khuôn mặt: $e',
        faceSize: 0,
      );
    }
  }
}