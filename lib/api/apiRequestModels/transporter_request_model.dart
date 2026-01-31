// To parse this JSON data, do
//
//     final transporterRequest = transporterRequestFromJson(jsonString);

import 'dart:convert';

TransporterRequest transporterRequestFromJson(str) => TransporterRequest.fromJson(json.decode(str));

String transporterRequestToJson(TransporterRequest data) => json.encode(data.toJson());

class TransporterRequest {
  List<InputDatum>? inputData;

  TransporterRequest({
    this.inputData,
  });

  factory TransporterRequest.fromJson(Map<String, dynamic> json) => TransporterRequest(
    inputData: json["input_data"] == null ? [] : List<InputDatum>.from(json["input_data"]!.map((x) => InputDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "input_data": inputData == null ? [] : List<dynamic>.from(inputData!.map((x) => x.toJson())),
  };
}

class InputDatum {
  String? key;
  List<Studio>? studios;

  InputDatum({
    this.key,
    this.studios,
  });

  factory InputDatum.fromJson(Map<String, dynamic> json) => InputDatum(
    key: json["key"],
    studios: json["studios"] == null ? [] : List<Studio>.from(json["studios"]!.map((x) => Studio.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "studios": studios == null ? [] : List<dynamic>.from(studios!.map((x) => x.toJson())),
  };
}

class Studio {
  String? code;
  int? lastUpdatedAt;

  Studio({
    this.code,
    this.lastUpdatedAt,
  });

  factory Studio.fromJson(Map<String, dynamic> json) => Studio(
    code: json["code"],
    lastUpdatedAt: json["last_updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "last_updated_at": lastUpdatedAt,
  };
}
