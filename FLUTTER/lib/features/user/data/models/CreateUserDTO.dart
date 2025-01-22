enum Gender { male, female, other } // Enum để ánh xạ giới tính

class CreateUserDTO {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final Gender gender;

  CreateUserDTO({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.gender,
  });

  // Chuyển đổi lớp DTO thành JSON để gửi đến backend
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "gender": gender.name, // Chuyển enum thành chuỗi
    };
  }
}
