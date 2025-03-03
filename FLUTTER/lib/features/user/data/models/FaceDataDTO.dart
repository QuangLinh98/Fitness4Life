class FaceDataDTO {
  final int userId;
  final String faceEncoding;
  final String originalImagePath;
  final bool hasFaceData;

  FaceDataDTO({
    required this.userId,
    required this.faceEncoding,
    required this.originalImagePath,
    required this.hasFaceData,
  });

  factory FaceDataDTO.fromJson(Map<String, dynamic> json) {
    return FaceDataDTO(
      userId: json['userId'] ?? 0,
      faceEncoding: json['faceEncoding'] ?? "",
      originalImagePath: json['originalImagePath'] ?? "",
      hasFaceData: json['hasFaceData'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'faceEncoding': faceEncoding,
      'originalImagePath': originalImagePath,
      'hasFaceData': hasFaceData,
    };
  }
}