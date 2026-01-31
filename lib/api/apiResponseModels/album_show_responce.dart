// To parse this JSON data, do
//
//     final albumShowResponse = albumShowResponseFromJson(jsonString);

import 'dart:convert';

AlbumShowResponse albumShowResponseFromJson(str) => AlbumShowResponse.fromJson(json.decode(str));

String albumShowResponseToJson(AlbumShowResponse data) => json.encode(data.toJson());

class AlbumShowResponse {
  int? updateRequired;
  Data? data;

  AlbumShowResponse({
    this.updateRequired,
    this.data,
  });

  factory AlbumShowResponse.fromJson(Map<String, dynamic> json) => AlbumShowResponse(
    updateRequired: json["update_required"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "update_required": updateRequired,
    "data": data?.toJson(),
  };
}

class Data {
  String? code;
  String? name;
  int? albumType;
  AlbumSize? albumSize;
  List<dynamic>? jvtFileConnectors;
  List<Order>? orders;
  int? lastUpdatedAt;
  List<dynamic>? persons;
  AlbumPath? albumPath;

  Data({
    this.code,
    this.name,
    this.albumType,
    this.albumSize,
    this.jvtFileConnectors,
    this.orders,
    this.lastUpdatedAt,
    this.persons,
    this.albumPath,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    code: json["code"],
    name: json["name"],
    albumType: json["album_type"],
    albumSize: json["album_size"] == null ? null : AlbumSize.fromJson(json["album_size"]),
    jvtFileConnectors: json["jvt_file_connectors"] == null ? [] : List<dynamic>.from(json["jvt_file_connectors"]!.map((x) => x)),
    orders: json["orders"] == null ? [] : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
    lastUpdatedAt: json["last_updated_at"],
    persons: json["persons"] == null ? [] : List<dynamic>.from(json["persons"]!.map((x) => x)),
    albumPath: json["album_path"] == null ? null : AlbumPath.fromJson(json["album_path"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "album_type": albumType,
    "album_size": albumSize?.toJson(),
    "jvt_file_connectors": jvtFileConnectors == null ? [] : List<dynamic>.from(jvtFileConnectors!.map((x) => x)),
    "orders": orders == null ? [] : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "last_updated_at": lastUpdatedAt,
    "persons": persons == null ? [] : List<dynamic>.from(persons!.map((x) => x)),
    "album_path": albumPath?.toJson(),
  };
}

class AlbumPath {
  String? code;
  String? path;
  String? desktopDeviceUuid;
  int? lastUpdatedAt;

  AlbumPath({
    this.code,
    this.path,
    this.desktopDeviceUuid,
    this.lastUpdatedAt,
  });

  factory AlbumPath.fromJson(Map<String, dynamic> json) => AlbumPath(
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

class AlbumSize {
  String? type;
  String? size;

  AlbumSize({
    this.type,
    this.size,
  });

  factory AlbumSize.fromJson(Map<String, dynamic> json) => AlbumSize(
    type: json["type"],
    size: json["size"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "size": size,
  };
}

class Order {
  String? code;
  int? imageType;
  int? priority;
  String? originalFileName;
  List<JvtFileConnector>? jvtFileConnectors;
  int? lastUpdatedAt;

  Order({
    this.code,
    this.imageType,
    this.priority,
    this.originalFileName,
    this.jvtFileConnectors,
    this.lastUpdatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    code: json["code"],
    imageType: json["image_type"],
    priority: json["priority"],
    originalFileName: json["original_file_name"],
    jvtFileConnectors: json["jvt_file_connectors"] == null ? [] : List<JvtFileConnector>.from(json["jvt_file_connectors"]!.map((x) => JvtFileConnector.fromJson(x))),
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "image_type": imageType,
    "priority": priority,
    "original_file_name": originalFileName,
    "jvt_file_connectors": jvtFileConnectors == null ? [] : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
    "last_updated_at": lastUpdatedAt,
  };
}

class JvtFileConnector {
  String? code;
  dynamic name;
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
