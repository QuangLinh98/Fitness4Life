class Branch {
  int? id;

  Branch({this.id});

  Branch copyWith({int? id}) => Branch(id: id ?? this.id);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    return map;
  }

  Branch.fromJson(dynamic json){
    id = json["id"];
  }
}

class Rooms {
  int? id;

  Rooms({this.id});

  Rooms copyWith({int? id}) => Rooms(id: id ?? this.id);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    return map;
  }

  Rooms.fromJson(dynamic json){
    id = json["id"];
  }
}

class Trainer {
  int? id;
  String? fullname;
  String? slug;
  String? photo;
  String? specialization;
  double? experienceyear;
  String? certificate;
  String? phonenumber;
  List<String>? scheduletrainersList;
  DateTime? createat;
  DateTime? updateat;
  Branch? branch;
  List<Rooms>? roomsList;

  Trainer(
      {this.id, this.fullname, this.slug, this.photo, this.specialization, this.experienceyear, this.certificate, this.phonenumber, this.scheduletrainersList, this.createat, this.updateat, this.branch, this.roomsList});


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["fullName"] = fullname;
    map["slug"] = slug;
    map["photo"] = photo;
    map["specialization"] = specialization;
    map["experienceYear"] = experienceyear;
    map["certificate"] = certificate;
    map["phoneNumber"] = phonenumber;
    map["scheduleTrainers"] = scheduletrainersList;
    map["createAt"] = createat?.toIso8601String();
    map["updateAt"] = updateat?.toIso8601String();
    if (branch != null) {
      map["branch"] = branch?.toJson();
    }
    if (roomsList != null) {
      map["rooms"] = roomsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  Trainer.fromJson(dynamic json){
    id = json["id"];
    fullname = json["fullName"];
    slug = json["slug"];
    photo = json["photo"];
    specialization = json["specialization"];
    experienceyear = json["experienceYear"];
    certificate = json["certificate"];
    phonenumber = json["phoneNumber"];
    scheduletrainersList = json["scheduleTrainers"] != null
        ? json["scheduleTrainers"].cast<String>()
        : [];
    createat = _convertToDateTime(json["createAt"]); // Xử lý createAt
    updateat = _convertToDateTime(json["updateAt"]); // Xử lý updateAt
    branch = json["branch"] != null ? Branch.fromJson(json["branch"]) : null;
    if (json["rooms"] != null) {
      roomsList = [];
      json["rooms"].forEach((v) {
        roomsList?.add(Rooms.fromJson(v));
      });
    }
  }

  // Hàm chuyển đổi LocalDateTime từ backend về DateTime
  DateTime? _convertToDateTime(dynamic json) {
    if (json == null || json is! List) return null;

    try {
      return DateTime(
        json[0], // Year
        json[1], // Month
        json[2], // Day
        json[3], // Hour
        json[4], // Minute
        json[5], // Second
        (json.length > 6 ? json[6] ~/ 1000 : 0), // Milliseconds (nếu có)
      );
    } catch (e) {
      print("Error converting LocalDateTime: $e");
      return null;
    }
  }
}