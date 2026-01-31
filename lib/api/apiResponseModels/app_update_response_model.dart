// To parse this JSON data, do
//
//     final appUpdate = appUpdateFromJson(jsonString);

import 'dart:convert';

AppUpdate appUpdateFromJson(str) => AppUpdate.fromJson(json.decode(str));

String appUpdateToJson(AppUpdate data) => json.encode(data.toJson());

class AppUpdate {
  int? appUpdateStatus;

  AppUpdate({
    this.appUpdateStatus,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) => AppUpdate(
    appUpdateStatus: json["app_update_status"],
  );

  Map<String, dynamic> toJson() => {
    "app_update_status": appUpdateStatus,
  };
}
