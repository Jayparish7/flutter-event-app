// To parse this JSON data, do
//
//     final studioIndex = studioIndexFromJson(jsonString);

import 'dart:convert';

StudioIndex studioIndexFromJson(str) => StudioIndex.fromJson(json.decode(str));

String studioIndexToJson(StudioIndex data) => json.encode(data.toJson());

class StudioIndex {
  List<Datum>? data;

  StudioIndex({
    this.data,
  });

  factory StudioIndex.fromJson(Map<String, dynamic> json) => StudioIndex(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? name;
  String? code;
  int? lastUpdatedAt;

  Datum({
    this.name,
    this.code,
    this.lastUpdatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    code: json["code"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "code": code,
    "last_updated_at": lastUpdatedAt,
  };
}
