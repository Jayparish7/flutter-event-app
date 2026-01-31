// To parse this JSON data, do
//
//     final addEventRequest = addEventRequestFromJson(jsonString);

import 'dart:convert';

AddEventRequest addEventRequestFromJson(str) =>
    AddEventRequest.fromJson(json.decode(str));

String addEventRequestToJson(AddEventRequest data) =>
    json.encode(data.toJson());

class AddEventRequest {
  List<Event>? events;
  String? studioCode;

  AddEventRequest({
    this.events,
    this.studioCode,
  });

  factory AddEventRequest.fromJson(Map<String, dynamic> json) =>
      AddEventRequest(
        events: json["events"] == null
            ? []
            : List<Event>.from(json["events"]!.map((x) => Event.fromJson(x))),
        studioCode: json["studio_code"],
      );

  Map<String, dynamic> toJson() => {
        "events": events == null
            ? []
            : List<dynamic>.from(events!.map((x) => x.toJson())),
        "studio_code": studioCode,
      };
}

class Event {
  String? code;
  int? lastUpdatedAt;
  int? confirmedLastUpdated_at;

  Event({
    this.code,
    this.lastUpdatedAt,
    this.confirmedLastUpdated_at,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        code: json["code"],
        lastUpdatedAt: json["last_updated_at"],
        confirmedLastUpdated_at: json["confirmed_last_updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "last_updated_at": lastUpdatedAt,
        "confirmed_last_updated_at": confirmedLastUpdated_at,
      };
}
