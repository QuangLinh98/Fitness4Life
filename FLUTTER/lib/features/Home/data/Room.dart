import 'Trainer.dart';

class Room {
  int? id;
  String? roomname;
  String? slug;
  int? capacity;
  int? availableseats;
  String? facilities;
  bool? status;
  List<int>? starttimeList;
  List<int>? endtimeList;
  List<int>? createdatList;
  List<int>? updatedatList;
  late bool isBooked;
  Trainer? trainer;

  Room({
    this.id,
    this.roomname,
    this.slug,
    this.capacity,
    this.availableseats,
    this.facilities,
    this.status,
    this.starttimeList,
    this.endtimeList,
    this.createdatList,
    this.updatedatList,
    this.isBooked = false,
    this.trainer,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["roomName"] = roomname;
    map["slug"] = slug;
    map["capacity"] = capacity;
    map["availableSeats"] = availableseats;
    map["facilities"] = facilities;
    map["status"] = status;
    map["startTime"] = starttimeList;
    map["endTime"] = endtimeList;
    map["createdAt"] = createdatList;
    map["updatedAt"] = updatedatList;
    map["isBooked"] = isBooked;
    map["trainer"] = trainer?.toJson();
    return map;
  }

  Room.fromJson(dynamic json){
    id = json["id"];
    roomname = json["roomName"];
    slug = json["slug"];
    capacity = json["capacity"];
    availableseats = json["availableSeats"];
    facilities = json["facilities"];
    status = json["status"];
    starttimeList =
    json["startTime"] != null ? json["startTime"].cast<int>() : [];
    endtimeList = json["endTime"] != null ? json["endTime"].cast<int>() : [];
    createdatList =
    json["createdAt"] != null ? json["createdAt"].cast<int>() : [];
    updatedatList =
    json["updatedAt"] != null ? json["updatedAt"].cast<int>() : [];
    isBooked = false;
    trainer = json["trainer"] != null ? Trainer.fromJson(json["trainer"]) : null;
  }
}