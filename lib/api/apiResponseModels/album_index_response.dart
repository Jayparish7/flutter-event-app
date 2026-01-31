// To parse this JSON data, do
//
//     final albumIndexResponse = albumIndexResponseFromJson(jsonString);

import 'dart:convert';

AlbumIndexResponse albumIndexResponseFromJson(str) =>
    AlbumIndexResponse.fromJson(json.decode(str));

String albumIndexResponseToJson(AlbumIndexResponse data) =>
    json.encode(data.toJson());

class AlbumIndexResponse {
  List<Media>? medias;

  AlbumIndexResponse({
    this.medias,
  });

  factory AlbumIndexResponse.fromJson(Map<String, dynamic> json) =>
      AlbumIndexResponse(
        medias: json["medias"] == null
            ? []
            : List<Media>.from(json["medias"]!.map((x) => Media.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "medias": medias == null
            ? []
            : List<dynamic>.from(medias!.map((x) => x.toJson())),
      };
}

class Media {
  String? code;
  int? priorityScore;
  int? published;
  String? mediableType;
  Mediable? mediable;
  int? lastUpdatedAt;
  int? createdInThisDevice;

  Media({
    this.code,
    this.priorityScore,
    this.published,
    this.mediableType,
    this.mediable,
    this.lastUpdatedAt,
    this.createdInThisDevice,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        code: json["code"],
        priorityScore: json["priority_score"],
        published: json["published"],
        mediableType: json["mediable_type"],
        mediable: json["mediable"] == null
            ? null
            : Mediable.fromJson(json["mediable"]),
        lastUpdatedAt: json["last_updated_at"],
        createdInThisDevice: json["created_in_this_device"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "priority_score": priorityScore,
        "published": published,
        "mediable_type": mediableType,
        "mediable": mediable?.toJson(),
        "last_updated_at": lastUpdatedAt,
        "created_in_this_device": createdInThisDevice,
      };
}

class Mediable {
  String? code;
  String? name;
  int? albumType;
  AlbumSize? albumSize;
  List<JvtFileConnector>? jvtFileConnectors;
  List<dynamic>? persons;
  AlbumPath? albumPath;

  Mediable({
    this.code,
    this.name,
    this.albumType,
    this.albumSize,
    this.jvtFileConnectors,
    this.persons,
    this.albumPath,
  });

  factory Mediable.fromJson(Map<String, dynamic> json) => Mediable(
        code: json["code"],
        name: json["name"],
        albumType: json["album_type"],
        albumSize: json["album_size"] == null
            ? null
            : AlbumSize.fromJson(json["album_size"]),
        jvtFileConnectors: json["jvt_file_connectors"] == null
            ? []
            : List<JvtFileConnector>.from(json["jvt_file_connectors"]!
                .map((x) => JvtFileConnector.fromJson(x))),
        persons: json["persons"] == null
            ? []
            : List<dynamic>.from(json["persons"]!.map((x) => x)),
        albumPath: json["album_path"] == null
            ? null
            : AlbumPath.fromJson(json["album_path"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "album_type": albumType,
        "album_size": albumSize?.toJson(),
        "jvt_file_connectors": jvtFileConnectors == null
            ? []
            : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
        "persons":
            persons == null ? [] : List<dynamic>.from(persons!.map((x) => x)),
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

  factory JvtFileConnector.fromJson(Map<String, dynamic> json) =>
      JvtFileConnector(
        code: json["code"],
        name: json["name"],
        screenDisplay: json["screen_display"],
        jvtFile: json["jvt_file"] == null
            ? null
            : JvtFile.fromJson(json["jvt_file"]),
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
