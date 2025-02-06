class GetUser {
  int? id;
  String? fullname;

  GetUser({this.id, this.fullname});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["fullName"] = fullname;
    return map;
  }

  GetUser.fromJson(dynamic json){
    id = json["id"];
    fullname = json["fullName"];
  }
}