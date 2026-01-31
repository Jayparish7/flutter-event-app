// To parse this JSON data, do
//
//     final folderStore = folderStoreFromJson(jsonString);

import 'dart:convert';

FolderStore folderStoreFromJson(str) => FolderStore.fromJson(json.decode(str));

String folderStoreToJson(FolderStore data) => json.encode(data.toJson());

class FolderStore {
  Data? data;

  FolderStore({
    this.data,
  });

  factory FolderStore.fromJson(Map<String, dynamic> json) => FolderStore(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
  };
}

class Data {
  String? code;
  String? name;
  String? parentCode;
  dynamic rule;
  List<dynamic>? photoSelectionImages;
  dynamic folderPath;
  int? lastUpdatedAt;

  Data({
    this.code,
    this.name,
    this.parentCode,
    this.rule,
    this.photoSelectionImages,
    this.folderPath,
    this.lastUpdatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    code: json["code"],
    name: json["name"],
    parentCode: json["parent_code"],
    rule: json["rule"],
    photoSelectionImages: json["photo_selection_images"] == null ? [] : List<dynamic>.from(json["photo_selection_images"]!.map((x) => x)),
    folderPath: json["folder_path"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "parent_code": parentCode,
    "rule": rule,
    "photo_selection_images": photoSelectionImages == null ? [] : List<dynamic>.from(photoSelectionImages!.map((x) => x)),
    "folder_path": folderPath,
    "last_updated_at": lastUpdatedAt,
  };
}
