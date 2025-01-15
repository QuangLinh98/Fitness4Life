class Tokens {
  int? id;
  String? value;
  String? type;

  Tokens({this.id, this.value, this.type});

  Tokens copyWith({int? id, String? value, String? type}) =>
      Tokens(id: id ?? this.id,
          value: value ?? this.value,
          type: type ?? this.type);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["value"] = value;
    map["type"] = type;
    return map;
  }

  Tokens.fromJson(dynamic json){
    id = json["id"];
    value = json["value"];
    type = json["type"];
  }
}

class User {
  int? id;
  int? workoutpackageid;
  String? fullname;
  String? email;
  String? password;
  bool? isbanned;
  bool? isactive;
  String? otpcode;
  String? expirytime;
  String? phone;
  String? role;
  String? gender;
  String? createat;
  List<Tokens>? tokensList;

  User(
      {this.id, this.workoutpackageid, this.fullname, this.email, this.password, this.isbanned, this.isactive, this.otpcode, this.expirytime, this.phone, this.role, this.gender, this.createat, this.tokensList});

  User copyWith(
      {int? id, int? workoutpackageid, String? fullname, String? email, String? password, bool? isbanned, bool? isactive, String? otpcode, String? expirytime, String? phone, String? role, String? gender, String? createat, List<
          Tokens>? tokensList}) =>
      User(id: id ?? this.id,
          workoutpackageid: workoutpackageid ?? this.workoutpackageid,
          fullname: fullname ?? this.fullname,
          email: email ?? this.email,
          password: password ?? this.password,
          isbanned: isbanned ?? this.isbanned,
          isactive: isactive ?? this.isactive,
          otpcode: otpcode ?? this.otpcode,
          expirytime: expirytime ?? this.expirytime,
          phone: phone ?? this.phone,
          role: role ?? this.role,
          gender: gender ?? this.gender,
          createat: createat ?? this.createat,
          tokensList: tokensList ?? this.tokensList);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["workoutPackageId"] = workoutpackageid;
    map["fullName"] = fullname;
    map["email"] = email;
    map["password"] = password;
    map["isBanned"] = isbanned;
    map["isActive"] = isactive;
    map["otpCode"] = otpcode;
    map["expiryTime"] = expirytime;
    map["phone"] = phone;
    map["role"] = role;
    map["gender"] = gender;
    map["createAt"] = createat;
    if (tokensList != null) {
      map["tokens"] = tokensList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  User.fromJson(dynamic json){
    id = json["id"];
    workoutpackageid = json["workoutPackageId"];
    fullname = json["fullName"];
    email = json["email"];
    password = json["password"];
    isbanned = json["isBanned"];
    isactive = json["isActive"];
    otpcode = json["otpCode"];
    expirytime = json["expiryTime"];
    phone = json["phone"];
    role = json["role"];
    gender = json["gender"];
    createat = json["createAt"];
    if (json["tokens"] != null) {
      tokensList = [];
      json["tokens"].forEach((v) {
        tokensList?.add(Tokens.fromJson(v));
      });
    }
  }
}