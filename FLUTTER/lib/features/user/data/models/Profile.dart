
enum Gender { MALE, FEMALE, OTHER }
enum MaritalStatus { SINGLE, MARRIED, FA }

class UserAndProfileUpdateDTO {
  String? fullName;
  String? role;
  Gender? gender;
  bool? status;
  String? phone;
  String? hobbies;
  String? address;
  int? age;
  int? heightValue;
  String? avatar;
  MaritalStatus? maritalStatus;
  String? description;

  UserAndProfileUpdateDTO({
    this.fullName,
    this.role,
    this.gender,
    this.status,
    this.phone,
    this.hobbies,
    this.address,
    this.age,
    this.heightValue,
    this.avatar,
    this.maritalStatus,
    this.description,
  });

  factory UserAndProfileUpdateDTO.fromJson(Map<String, dynamic> json) {
    return UserAndProfileUpdateDTO(
      fullName: json['full_name'],
      role: json['role'],
      gender: Gender.values.firstWhere(
            (e) => e.toString().split('.').last == json['packageName'],
        orElse: () => Gender.MALE,
      ),
      status: json['status'],
      phone: json['phone'],
      hobbies: json['hobbies'],
      address: json['address'],
      age: json['age'],
      heightValue: json['height_value'],
      avatar: json['avatar'],
      maritalStatus: MaritalStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['packageName'],
        orElse: () => MaritalStatus.SINGLE,
      ),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'role': role,
      'gender': gender.toString().split('.').last,
      'status': status,
      'phone': phone,
      'hobbies': hobbies,
      'address': address,
      'age': age,
      'height_value': heightValue,
      'avatar': avatar,
      'marital_status': maritalStatus.toString().split('.').last,
      'description': description,
    };
  }

}




