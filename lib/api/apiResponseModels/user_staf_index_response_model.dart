// To parse this JSON data, do
//
//     final userStaffGroupsIndex = userStaffGroupsIndexFromJson(jsonString);

import 'dart:convert';

UserStaffGroupsIndex userStaffGroupsIndexFromJson( str) => UserStaffGroupsIndex.fromJson(json.decode(str));

String userStaffGroupsIndexToJson(UserStaffGroupsIndex data) => json.encode(data.toJson());

class UserStaffGroupsIndex {
  List<Datum>? data;

  UserStaffGroupsIndex({
    this.data,
  });

  factory UserStaffGroupsIndex.fromJson(Map<String, dynamic> json) => UserStaffGroupsIndex(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? studioRandomId;
  String? role;

  Datum({
    this.studioRandomId,
    this.role,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    studioRandomId: json["studio_random_id"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "studio_random_id": studioRandomId,
    "role": role,
  };
}
