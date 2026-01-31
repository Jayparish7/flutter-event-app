// To parse this JSON data, do
//
//     final addUserResponseModel = addUserResponseModelFromJson(jsonString);

import 'dart:convert';

AddUserResponseModel addUserResponseModelFromJson(str) => AddUserResponseModel.fromJson(json.decode(str));

String addUserResponseModelToJson(AddUserResponseModel data) => json.encode(data.toJson());

class AddUserResponseModel {
  String? message;
  String? user;

  AddUserResponseModel({
    this.message,
    this.user,
  });

  factory AddUserResponseModel.fromJson(Map<String, dynamic> json) => AddUserResponseModel(
    message: json["message"],
    user: json["user"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "user": user,
  };
}
