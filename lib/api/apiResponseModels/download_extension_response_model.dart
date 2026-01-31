// To parse this JSON data, do
//
//     final downloadExtensionIndexModel = downloadExtensionIndexModelFromJson(jsonString);

import 'dart:convert';

DownloadExtensionIndexModel downloadExtensionIndexModelFromJson(str) => DownloadExtensionIndexModel.fromJson(json.decode(str));

String downloadExtensionIndexModelToJson(DownloadExtensionIndexModel data) => json.encode(data.toJson());

class DownloadExtensionIndexModel {
  List<Datum> data;

  DownloadExtensionIndexModel({
    required this.data,
  });

  factory DownloadExtensionIndexModel.fromJson(Map<String, dynamic> json) => DownloadExtensionIndexModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String code;
  String extension;

  Datum({
    required this.code,
    required this.extension,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    code: json["code"],
    extension: json["extension"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "extension": extension,
  };
}
