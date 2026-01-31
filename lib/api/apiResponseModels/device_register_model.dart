import 'dart:convert';

import 'package:photomall_studio_manager/api/apiResponseModels/country_model.dart';

/// Model class for device register api

DeviceRegisterModel deviceRegisterModelFromJson(str) =>
    DeviceRegisterModel.fromJson(json.decode(str));

String deviceRegisterModelToJson(DeviceRegisterModel data) =>
    json.encode(data.toJson());

class DeviceRegisterModel {
  RegData? data;

  DeviceRegisterModel({
    this.data,
  });

  factory DeviceRegisterModel.fromJson(Map<String, dynamic> json) =>
      DeviceRegisterModel(
        data: RegData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class RegData {
  int? clientId;
  String? clientSecret;
  String? encryptionKey;
  List<Country>? countries;

  RegData({
    this.clientId,
    this.clientSecret,
    this.encryptionKey,
    this.countries,
  });

  factory RegData.fromJson(Map<String, dynamic> json) => RegData(
    clientId: json["client_id"],
    clientSecret: json["client_secret"],
    encryptionKey: json["en_key"],
    countries: json["countries"] == null ? [] : List<Country>.from(json["countries"]!.map((x) => Country.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "client_secret": clientSecret,
    "en_key": encryptionKey,
    "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
  };
}
