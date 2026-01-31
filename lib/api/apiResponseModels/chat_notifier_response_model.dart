// To parse this JSON data, do
//
//     final errorNotifier = errorNotifierFromJson(jsonString);

import 'dart:convert';

ErrorNotifier errorNotifierFromJson(str) => ErrorNotifier.fromJson(json.decode(str));

String errorNotifierToJson(ErrorNotifier data) => json.encode(data.toJson());

class ErrorNotifier {
  ErrorNotifier({
    this.status,
    this.message,
  });

  bool? status;
  String? message;

  factory ErrorNotifier.fromJson(Map<String, dynamic> json) => ErrorNotifier(
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? null : status,
    "message": message == null ? null : message,
  };
}
