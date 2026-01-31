// To parse this JSON data, do
//
//     final addEventResponse = addEventResponseFromJson(jsonString);

import 'dart:convert';

List<AddEventResponse> addEventResponseFromJson(str) => List<AddEventResponse>.from(json.decode(str).map((x) => AddEventResponse.fromJson(x)));

String addEventResponseToJson(List<AddEventResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
AddEventResponse singleAddEventResponseFromJson(String str) =>
    AddEventResponse.fromJson(json.decode(str));
class AddEventResponse {
  String? code;
  int? status;
  int? updateRequired;
  int? confirmedUpdateRequired;
  int? confirmedLastUpdatedAt;
  Data? data;
  String? message;

  AddEventResponse({
    this.code,
    this.status,
    this.confirmedUpdateRequired,
    this.confirmedLastUpdatedAt,
    this.updateRequired,
    this.data,
    this.message,
  });

  factory AddEventResponse.fromJson(Map<String, dynamic> json) => AddEventResponse(
    code: json["code"],
    status: json["status"],
    updateRequired: json["update_required"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    confirmedUpdateRequired: json["confirmed_update_required"],
    confirmedLastUpdatedAt: json["confirmed_last_updated_at"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "update_required": updateRequired,
    "confirmed_update_required": confirmedUpdateRequired,
    "confirmed_last_updated_at": confirmedLastUpdatedAt,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  String? code;
  String? name;
  String? categoryName;
  int? published;
  List<JvtFileConnector>? jvtFileConnectors;
  StudioUser? studioUser;
  int? confirmedStatus;
  int? lastUpdatedAt;
  int? screenDisplay;
  String? photoselectionCode;

  Data({
    this.code,
    this.name,
    this.categoryName,
    this.published,
    this.jvtFileConnectors,
    this.studioUser,
    this.confirmedStatus,
    this.lastUpdatedAt,
    this.screenDisplay,
    this.photoselectionCode,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    code: json["code"],
    name: json["name"],
    categoryName: json["category_name"],
    published: json["published"],
    jvtFileConnectors: json["jvt_file_connectors"] == null ? [] : List<JvtFileConnector>.from(json["jvt_file_connectors"]!.map((x) => JvtFileConnector.fromJson(x))),
    studioUser: json["studio_user"] == null ? null : StudioUser.fromJson(json["studio_user"]),
    confirmedStatus: json["confirmed_status"],
    lastUpdatedAt: json["last_updated_at"],
    screenDisplay: json["screen_display"],
    photoselectionCode: json["photoselection_code"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "category_name": categoryName,
    "published": published,
    "jvt_file_connectors": jvtFileConnectors == null ? [] : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
    "studio_user": studioUser?.toJson(),
    "confirmed_status": confirmedStatus,
    "last_updated_at": lastUpdatedAt,
    "photoselection_code": photoselectionCode,
    "screen_display": screenDisplay,
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

class StudioUser {
  String? name;

  StudioUser({
    this.name,
  });

  factory StudioUser.fromJson(Map<String, dynamic> json) => StudioUser(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}
