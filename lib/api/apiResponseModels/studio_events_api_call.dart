// To parse this JSON data, do
//
//     final studioEventsResponseModel = studioEventsResponseModelFromJson(jsonString);

import 'dart:convert';

StudioEventsResponseModel studioEventsResponseModelFromJson(str) => StudioEventsResponseModel.fromJson(json.decode(str));

String studioEventsResponseModelToJson(StudioEventsResponseModel data) => json.encode(data.toJson());

class StudioEventsResponseModel {
  List<PhotomallEventCode>? photomallEventCodes;

  StudioEventsResponseModel({
    this.photomallEventCodes,
  });

  factory StudioEventsResponseModel.fromJson(Map<String, dynamic> json) => StudioEventsResponseModel(
    photomallEventCodes: json["photomall_event_codes"] == null ? [] : List<PhotomallEventCode>.from(json["photomall_event_codes"]!.map((x) => PhotomallEventCode.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "photomall_event_codes": photomallEventCodes == null ? [] : List<dynamic>.from(photomallEventCodes!.map((x) => x.toJson())),
  };
}

class PhotomallEventCode {
  String? eventCode;
  String? eventCreatedAt;

  PhotomallEventCode({
    this.eventCode,
    this.eventCreatedAt,
  });

  factory PhotomallEventCode.fromJson(Map<String, dynamic> json) => PhotomallEventCode(
    eventCode: json["event_code"],
    eventCreatedAt: json["event_created_at"],
  );

  Map<String, dynamic> toJson() => {
    "event_code": eventCode,
    "event_created_at": eventCreatedAt,
  };
}
