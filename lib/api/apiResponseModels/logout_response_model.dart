// To parse this JSON data, do
//
//     final logout = logoutFromJson(jsonString);

import 'dart:convert';

Logout logoutFromJson(str) => Logout.fromJson(json.decode(str));

String logoutToJson(Logout data) => json.encode(data.toJson());

class Logout {
  String? successMessage;

  Logout({
    this.successMessage,
  });

  factory Logout.fromJson(Map<String, dynamic> json) => Logout(
    successMessage: json["success_message"],
  );

  Map<String, dynamic> toJson() => {
    "success_message": successMessage,
  };
}
