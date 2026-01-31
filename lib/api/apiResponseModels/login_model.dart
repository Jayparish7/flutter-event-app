// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson( str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int status;
  String ?ableType;
  String ? token;
  String ? errorMessage;
  int ?clientId;

  LoginModel({
    required this.status,
     this.ableType,
     this.token,
     this.clientId,
     this.errorMessage,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"],
    ableType: json["able_type"],
    token: json["token"],
    clientId: json["client_id"],
    errorMessage: json["error_message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "able_type": ableType,
    "token": token,
    "client_id": clientId,
    "error_message": errorMessage,
  };
}
