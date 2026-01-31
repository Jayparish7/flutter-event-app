// To parse this JSON data, do
//
//     final preSignedUrlResponseModel = preSignedUrlResponseModelFromJson(jsonString);

import 'dart:convert';

PreSignedUrlResponseModel preSignedUrlResponseModelFromJson(str) => PreSignedUrlResponseModel.fromJson(json.decode(str));

String preSignedUrlResponseModelToJson(PreSignedUrlResponseModel data) => json.encode(data.toJson());

class PreSignedUrlResponseModel {
  String? presignedUrl;
  String? presignedUrlCode;
  String? errorMessage;

  PreSignedUrlResponseModel({
    this.presignedUrl,
    this.presignedUrlCode,
    this.errorMessage,
  });

  factory PreSignedUrlResponseModel.fromJson(Map<String, dynamic> json) => PreSignedUrlResponseModel(
    presignedUrl: json["presigned_url"],
    presignedUrlCode: json["presigned_url_code"],
    errorMessage: json["error_message"],
  );

  Map<String, dynamic> toJson() => {
    "presigned_url": presignedUrl,
    "presigned_url_code": presignedUrlCode,
    "error_message": errorMessage,
  };
}
