// To parse this JSON data, do
//
//     final photoSelectionResponse = photoSelectionResponseFromJson(jsonString);

import 'dart:convert';

PhotoSelectionResponse photoSelectionResponseFromJson(str) => PhotoSelectionResponse.fromJson(json.decode(str));

String photoSelectionResponseToJson(PhotoSelectionResponse data) => json.encode(data.toJson());

  class PhotoSelectionResponse {
  int? updateRequired;
  int? lastUpdatedAt;
  PhotoSelectionData? photoSelectionData;

  PhotoSelectionResponse({
    this.updateRequired,
    this.photoSelectionData,
    this.lastUpdatedAt,

  });

  factory PhotoSelectionResponse.fromJson(Map<String, dynamic> json) => PhotoSelectionResponse(
    updateRequired: json["update_required"],
    lastUpdatedAt: json["last_updated_at"],
    photoSelectionData: json["data"] == null ? null : PhotoSelectionData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "update_required": updateRequired,
    "data": photoSelectionData?.toJson(),
    "last_updated_at": lastUpdatedAt,

  };
}

class PhotoSelectionData {
  String? code;
  int? published;
  List<Folder>? folders;
  int? confirmedStatus;
  int? lastUpdatedAt;

  PhotoSelectionData({
    this.code,
    this.published,
    this.folders,
    this.confirmedStatus,
    this.lastUpdatedAt,
  });

  factory PhotoSelectionData.fromJson(Map<String, dynamic> json) => PhotoSelectionData(
    code: json["code"],
    published: json["published"],
    folders: json["folders"] == null ? [] : List<Folder>.from(json["folders"]!.map((x) => Folder.fromJson(x))),
    confirmedStatus: json["confirmed_status"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "published": published,
    "folders": folders == null ? [] : List<dynamic>.from(folders!.map((x) => x.toJson())),
    "confirmed_status": confirmedStatus,
    "last_updated_at": lastUpdatedAt,
  };
}

class Folder {
  String? code;
  String? name;
  String? parentCode;
  Rule? rule;
  List<PhotoSelectionImage>? photoSelectionImages;
  FolderPath? folderPath;
  int? lastUpdatedAt;

  Folder({
    this.code,
    this.name,
    this.parentCode,
    this.rule,
    this.photoSelectionImages,
    this.folderPath,
    this.lastUpdatedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    code: json["code"],
    name: json["name"],
    parentCode: json["parent_code"],
    rule: json["rule"] == null ? null : Rule.fromJson(json["rule"]),
    photoSelectionImages: json["photo_selection_images"] == null ? [] : List<PhotoSelectionImage>.from(json["photo_selection_images"]!.map((x) => PhotoSelectionImage.fromJson(x))),
    folderPath: json["folder_path"] == null ? null : FolderPath.fromJson(json["folder_path"]),
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "parent_code": parentCode,
    "rule": rule?.toJson(),
    "photo_selection_images": photoSelectionImages == null ? [] : List<dynamic>.from(photoSelectionImages!.map((x) => x.toJson())),
    "folder_path": folderPath?.toJson(),
    "last_updated_at": lastUpdatedAt,
  };
}

class FolderPath {
  String? code;
  String? path;
  String? desktopDeviceUuid;
  int? lastUpdatedAt;

  FolderPath({
    this.code,
    this.path,
    this.desktopDeviceUuid,
    this.lastUpdatedAt,
  });

  factory FolderPath.fromJson(Map<String, dynamic> json) => FolderPath(
    code: json["code"],
    path: json["path"],
    desktopDeviceUuid: json["desktop_device_uuid"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "path": path,
    "desktop_device_uuid": desktopDeviceUuid,
    "last_updated_at": lastUpdatedAt,
  };
}

class PhotoSelectionImage {
  String? code;
  String? originalFileName;

  PhotoSelectionImage({
    this.code,
    this.originalFileName,
  });

  factory PhotoSelectionImage.fromJson(Map<String, dynamic> json) => PhotoSelectionImage(
    code: json["code"],
    originalFileName: json["original_file_name"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "original_file_name": originalFileName,
  };
}

class Rule {
  String? code;
  int? minimumSelectionImages;
  int? maximumSelectionImages;
  int? lastUpdatedAt;

  Rule({
    this.code,
    this.minimumSelectionImages,
    this.maximumSelectionImages,
    this.lastUpdatedAt,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
    code: json["code"],
    minimumSelectionImages: json["minimum_selection_images"],
    maximumSelectionImages: json["maximum_selection_images"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "minimum_selection_images": minimumSelectionImages,
    "maximum_selection_images": maximumSelectionImages,
    "last_updated_at": lastUpdatedAt,
  };
}
