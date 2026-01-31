// To parse this JSON data, do
//
//     final addAlbumResponse = addAlbumResponseFromJson(jsonString);

import 'dart:convert';

AddAlbumResponse addAlbumResponseFromJson(str) => AddAlbumResponse.fromJson(json.decode(str));

String addAlbumResponseToJson(AddAlbumResponse data) => json.encode(data.toJson());

class AddAlbumResponse {
  Album? album;
  int? lastUpdatedAt;

  AddAlbumResponse({
    this.album,
    this.lastUpdatedAt,
  });

  factory AddAlbumResponse.fromJson(Map<String, dynamic> json) => AddAlbumResponse(
    album: json["album"] == null ? null : Album.fromJson(json["album"]),
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "album": album?.toJson(),
    "last_updated_at": lastUpdatedAt,
  };
}

class Album {
  String? code;
  String? name;
  int? albumType;
  AlbumSize? albumSize;
  int? lastUpdatedAt;
  AlbumPath? albumPath;

  Album({
    this.code,
    this.name,
    this.albumType,
    this.albumSize,
    this.lastUpdatedAt,
    this.albumPath,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
    code: json["code"],
    name: json["name"],
    albumType: json["album_type"],
    albumSize: json["album_size"] == null ? null : AlbumSize.fromJson(json["album_size"]),
    lastUpdatedAt: json["last_updated_at"],
    albumPath: json["album_path"] == null ? null : AlbumPath.fromJson(json["album_path"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "album_type": albumType,
    "album_size": albumSize?.toJson(),
    "last_updated_at": lastUpdatedAt,
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
