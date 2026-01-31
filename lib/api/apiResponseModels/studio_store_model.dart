// To parse this JSON data, do
//
//     final studioStore = studioStoreFromJson(jsonString);

import 'dart:convert';

StudioStoreresponse studioStoreFromJson(str) => StudioStoreresponse.fromJson(json.decode(str));

String studioStoreToJson(StudioStoreresponse data) => json.encode(data.toJson());

class StudioStoreresponse {
  List<Datum>? data;

  StudioStoreresponse({
    this.data,
  });

  factory StudioStoreresponse.fromJson(Map<String, dynamic> json) => StudioStoreresponse(
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
