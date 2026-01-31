// To parse this JSON data, do
//
//     final coverImageResponseModel = coverImageResponseModelFromJson(jsonString);

import 'dart:convert';

CoverImageResponseModel coverImageResponseModelFromJson(str) => CoverImageResponseModel.fromJson(json.decode(str));

String coverImageResponseModelToJson(CoverImageResponseModel data) => json.encode(data.toJson());

class CoverImageResponseModel {
  JvtFileConnector? jvtFileConnector;

  CoverImageResponseModel({
    this.jvtFileConnector,
  });

  factory CoverImageResponseModel.fromJson(Map<String, dynamic> json) => CoverImageResponseModel(
    jvtFileConnector: json["jvt_file_connector"] == null ? null : JvtFileConnector.fromJson(json["jvt_file_connector"]),
  );

  Map<String, dynamic> toJson() => {
    "jvt_file_connector": jvtFileConnector?.toJson(),
  };
}

class JvtFileConnector {
  String? code;
  String? name;
  int? screenDisplay;
  JvtFile? jvtFile;

  JvtFileConnector({
    this.code,
    this.name,
    this.screenDisplay,
    this.jvtFile,
  });

  factory JvtFileConnector.fromJson(Map<String, dynamic> json) => JvtFileConnector(
    code: json["code"],
    name: json["name"],
    screenDisplay: json["screen_display"],
    jvtFile: json["jvt_file"] == null ? null : JvtFile.fromJson(json["jvt_file"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "screen_display": screenDisplay,
    "jvt_file": jvtFile?.toJson(),
  };
}

class JvtFile {
  String? code;
  String? name;
  int? mode;
  int? size;
  String? extension;

  JvtFile({
    this.code,
    this.name,
    this.mode,
    this.size,
    this.extension,
  });

  factory JvtFile.fromJson(Map<String, dynamic> json) => JvtFile(
    code: json["code"],
    name: json["name"],
    mode: json["mode"],
    size: json["size"],
    extension: json["extension"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "mode": mode,
    "size": size,
    "extension": extension,
  };
}
