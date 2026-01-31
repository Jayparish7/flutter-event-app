// To parse this JSON data, do
//
//     final imageUploadResponse = imageUploadResponseFromJson(jsonString);

import 'dart:convert';

ImageUploadResponse imageUploadResponseFromJson(str) => ImageUploadResponse.fromJson(json.decode(str));

String imageUploadResponseToJson(ImageUploadResponse data) => json.encode(data.toJson());

class ImageUploadResponse {
  FileData? file;

  ImageUploadResponse({
    this.file,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) => ImageUploadResponse(
    file: json["file"] == null ? null : FileData.fromJson(json["file"]),
  );

  Map<String, dynamic> toJson() => {
    "file": file?.toJson(),
  };
}

class FileData {
  String? successOrError;
  String? ableType;
  String? code;
  String? successMessage;
  String? jvtFileCode;

  FileData({
    this.successOrError,
    this.ableType,
    this.code,
    this.successMessage,
    this.jvtFileCode,
  });

  factory FileData.fromJson(Map<String, dynamic> json) => FileData(
    successOrError: json["success_or_error"],
    ableType: json["able_type"],
    code: json["code"],
    successMessage: json["success_message"],
    jvtFileCode: json["jvt_file_code"],
  );

  Map<String, dynamic> toJson() => {
    "success_or_error": successOrError,
    "able_type": ableType,
    "code": code,
    "success_message": successMessage,
    "jvt_file_code": jvtFileCode,
  };
}
