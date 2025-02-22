import 'package:fitness4life/features/user/data/models/ProfileDTO.dart';

enum Roles { ADMIN, USER }
enum Gender { MALE, FEMALE, OTHER }
enum MaritalStatus { SINGLE, MARRIED, FA }

class UserResponseDTO {
  final int id;
  final String fullName;
  final int workoutPackageId;
  final String email;
  final bool isActive;
  final String phone;
  final Roles role;
  final Gender gender;
  final ProfileDTO profileDTO;

  UserResponseDTO({
    required this.id,
    required this.fullName,
    required this.workoutPackageId,
    required this.email,
    required this.isActive,
    required this.phone,
    required this.role,
    required this.gender,
    required this.profileDTO,
  });

  factory UserResponseDTO.fromJson(Map<String, dynamic> json) {
    return UserResponseDTO(
      id: json['id'],
      fullName: json['fullName'],
      workoutPackageId: json['workoutPackageId'],
      email: json['email'],
      isActive: json['isActive'] ?? false,
      phone: json['phone'],
      role: Roles.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'],
        orElse: () => Roles.USER,
      ),
      gender: Gender.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'],
        orElse: () => Gender.MALE,
      ),
      profileDTO: ProfileDTO.fromJson(json['profileDTO']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'workoutPackageId': workoutPackageId,
      'email': email,
      'isActive': isActive,
      'phone': phone,
      'role': role.toString().split('.').last,
      'gender': gender.toString().split('.').last,
      'profileDTO': profileDTO.toJson(),
    };
  }
}