// To parse this JSON data, do
//
//     final googleDriveFilesApiResponseModel = googleDriveFilesApiResponseModelFromJson(jsonString);

import 'dart:convert';

GoogleDriveFilesApiResponseModel googleDriveFilesApiResponseModelFromJson(
        str) =>
    GoogleDriveFilesApiResponseModel.fromJson(json.decode(str));

String googleDriveFilesApiResponseModelToJson(
        GoogleDriveFilesApiResponseModel data) =>
    json.encode(data.toJson());

class GoogleDriveFilesApiResponseModel {
  List<FileElement>? files;

  GoogleDriveFilesApiResponseModel({
    this.files,
  });

  factory GoogleDriveFilesApiResponseModel.fromJson(
          Map<String, dynamic> json) =>
      GoogleDriveFilesApiResponseModel(
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
  String? mimeType;

  FileElement({
    this.id,
    this.name,
    this.mimeType,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        name: json["name"],
        mimeType: json["mimeType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mimeType": mimeType,
      };
}
