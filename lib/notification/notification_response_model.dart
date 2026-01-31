// To parse this JSON data, do
//
//     final pendingNotificationModel = pendingNotificationModelFromJson(jsonString);

import 'dart:convert';

PendingNotificationModel pendingNotificationModelFromJson(str) => PendingNotificationModel.fromJson(json.decode(str));

String pendingNotificationModelToJson(PendingNotificationModel data) => json.encode(data.toJson());

class PendingNotificationModel {
  String? message;
  String? title;
  String? eventCode;
  String? photoSelectionCode;
  int? incompleteConfirmedStatus;

  PendingNotificationModel({
    this.message,
    this.title,
    this.eventCode,
    this.photoSelectionCode,
    this.incompleteConfirmedStatus,
  });

  factory PendingNotificationModel.fromJson(Map<String, dynamic> json) => PendingNotificationModel(
    message: json["message"],
    title: json["title"],
    eventCode: json["event_code"],
    photoSelectionCode: json["photoselection_code"],
    incompleteConfirmedStatus: json["incomplete_confirmed_status"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "title": title,
    "event_code": eventCode,
    "photoselection_code": photoSelectionCode,
    "incomplete_confirmed_status": incompleteConfirmedStatus,
  };
}
