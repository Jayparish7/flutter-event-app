// To parse this JSON data, do
//
//     final eventStoreResponseModel = eventStoreResponseModelFromJson(jsonString);

import 'dart:convert';

EventStoreResponseModel eventStoreResponseModelFromJson(str) => EventStoreResponseModel.fromJson(json.decode(str));

String eventStoreResponseModelToJson(EventStoreResponseModel data) => json.encode(data.toJson());

  class EventStoreResponseModel {
  String? photomallEventCode;
  String? errorMessage;

  EventStoreResponseModel({
    this.photomallEventCode,
    this.errorMessage,

  });

  factory EventStoreResponseModel.fromJson(Map<String, dynamic> json) => EventStoreResponseModel(
    photomallEventCode: json["photomall_event_code"],
    errorMessage: json["error_message"],
  );

  Map<String, dynamic> toJson() => {
    "photomall_event_code": photomallEventCode,
    "error_message": errorMessage,
  };
}
