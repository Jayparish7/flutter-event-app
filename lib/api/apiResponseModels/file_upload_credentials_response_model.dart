// To parse this JSON data, do
//
//     final fileUploadCredentialsResponseModel = fileUploadCredentialsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';

FileUploadCredentialsResponseModel fileUploadCredentialsResponseModelFromJson(
        str) =>
    FileUploadCredentialsResponseModel.fromJson(json.decode(str));

String fileUploadCredentialsResponseModelToJson(
        FileUploadCredentialsResponseModel data) =>
    json.encode(data.toJson());

class FileUploadCredentialsResponseModel {
  ScreenDisplay? screenDisplay;
  String? originalFilePath;

  FileUploadCredentialsResponseModel({
    this.screenDisplay,
    this.originalFilePath,
  });

  factory FileUploadCredentialsResponseModel.fromJson(
          Map<String, dynamic> json) =>
      FileUploadCredentialsResponseModel(
        originalFilePath: json["original_file_path"],
        screenDisplay: json["screen_display"] == null
            ? null
            : ScreenDisplay.fromJson(json["screen_display"]),
      );

  Map<String, dynamic> toJson() => {
        "screen_display": screenDisplay?.toJson(),
        "original_file_path": originalFilePath,
      };
}
