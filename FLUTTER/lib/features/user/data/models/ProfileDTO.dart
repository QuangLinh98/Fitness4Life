enum MaritalStatus { SINGLE, MARRIED, FA }

class ProfileDTO {
  final int id;
  final String hobbies;
  final String address;
  final int age;
  final int heightValue;
  final String avatar;
  final MaritalStatus maritalStatus;
  final String description;

  ProfileDTO({
    required this.id,
    required this.hobbies,
    required this.address,
    required this.age,
    required this.heightValue,
    required this.avatar,
    required this.maritalStatus,
    required this.description,
  });

  factory ProfileDTO.fromJson(Map<String, dynamic> json) {
    return ProfileDTO(
      id: json['id'],
      hobbies: json['hobbies'],
      address: json['address'],
      age: json['age'],
      heightValue: json['heightValue'],
      avatar: json['avatar'] ?? "",
      maritalStatus: MaritalStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['marital_status'],
        orElse: () => MaritalStatus.SINGLE,
      ),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hobbies': hobbies,
      'address': address,
      'age': age,
      'heightValue': heightValue,
      'avatar': avatar,
      'maritalStatus': maritalStatus.toString().split('.').last,
      'description': description,
    };
  }
}