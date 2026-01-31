// To parse this JSON data, do
//
//     final googleDriveApiResponseModel = googleDriveApiResponseModelFromJson(jsonString);

import 'dart:convert';

GoogleDriveApiResponseModel googleDriveApiResponseModelFromJson(str) =>
    GoogleDriveApiResponseModel.fromJson(json.decode(str));

String googleDriveApiResponseModelToJson(GoogleDriveApiResponseModel data) =>
    json.encode(data.toJson());

class GoogleDriveApiResponseModel {
  List<FileElement>? files;

  GoogleDriveApiResponseModel({
    this.files,
  });

  factory GoogleDriveApiResponseModel.fromJson(Map<String, dynamic> json) =>
      GoogleDriveApiResponseModel(
        files: json["files"] == null
            ? []
            : List<FileElement>.from(
                json["files"]!.map((x) => FileElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "files": files == null
            ? []
            : List<dynamic>.from(files!.map((x) => x.toJson())),
      };
}

class FileElement {
  String? id;
  String? name;

  FileElement({
    this.id,
    this.name,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
