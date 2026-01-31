// To parse this JSON data, do
//
//     final photoselectionReverseConfirmationResponseModel = photoselectionReverseConfirmationResponseModelFromJson(jsonString);

import 'dart:convert';

PhotoselectionReverseConfirmationResponseModel photoselectionReverseConfirmationResponseModelFromJson(str) => PhotoselectionReverseConfirmationResponseModel.fromJson(json.decode(str));

String photoselectionReverseConfirmationResponseModelToJson(PhotoselectionReverseConfirmationResponseModel data) => json.encode(data.toJson());

class PhotoselectionReverseConfirmationResponseModel {
  String? message;

  PhotoselectionReverseConfirmationResponseModel({
    this.message,
  });

  factory PhotoselectionReverseConfirmationResponseModel.fromJson(Map<String, dynamic> json) => PhotoselectionReverseConfirmationResponseModel(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}
