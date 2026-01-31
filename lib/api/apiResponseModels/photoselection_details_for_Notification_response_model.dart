// To parse this JSON data, do
//
//     final photoSelectionDetailsForNotificationResponseModel = photoSelectionDetailsForNotificationResponseModelFromJson(jsonString);

import 'dart:convert';

PhotoSelectionDetailsForNotificationResponseModel photoSelectionDetailsForNotificationResponseModelFromJson( str) => PhotoSelectionDetailsForNotificationResponseModel.fromJson(json.decode(str));

String photoSelectionDetailsForNotificationResponseModelToJson(PhotoSelectionDetailsForNotificationResponseModel data) => json.encode(data.toJson());

class PhotoSelectionDetailsForNotificationResponseModel {
  Data? data;

  PhotoSelectionDetailsForNotificationResponseModel({
    this.data,
  });

  factory PhotoSelectionDetailsForNotificationResponseModel.fromJson(Map<String, dynamic> json) => PhotoSelectionDetailsForNotificationResponseModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
  };
}

class Data {
  String? code;
  int? published;
  String? eventName;
  EventCoverImage? eventCoverImage;
  String? categoryName;
  List<ClientEvent>? clientEvents;
  int? numberOfFolders;
  int? totalImages;
  int? selectedImages;
  int? rejectedImages;
  int? undecidedImages;

  Data({
    this.code,
    this.published,
    this.eventName,
    this.eventCoverImage,
    this.categoryName,
    this.clientEvents,
    this.numberOfFolders,
    this.totalImages,
    this.selectedImages,
    this.rejectedImages,
    this.undecidedImages,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    code: json["code"],
    published: json["published"],
    eventName: json["event_name"],
    eventCoverImage: json["event_cover_image"] == null ? null : EventCoverImage.fromJson(json["event_cover_image"]),
    categoryName: json["category_name"],
    clientEvents: json["client_events"] == null ? [] : List<ClientEvent>.from(json["client_events"]!.map((x) => ClientEvent.fromJson(x))),
    numberOfFolders: json["number_of_folders"],
    totalImages: json["total_images"],
    selectedImages: json["selected_images"],
    rejectedImages: json["rejected_images"],
    undecidedImages: json["undecided_images"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "published": published,
    "event_name": eventName,
    "event_cover_image": eventCoverImage?.toJson(),
    "category_name": categoryName,
    "client_events": clientEvents == null ? [] : List<dynamic>.from(clientEvents!.map((x) => x.toJson())),
    "number_of_folders": numberOfFolders,
    "total_images": totalImages,
    "selected_images": selectedImages,
    "rejected_images": rejectedImages,
    "undecided_images": undecidedImages,
  };
}

class ClientEvent {
  String? userRandomId;

  ClientEvent({
    this.userRandomId,
  });

  factory ClientEvent.fromJson(Map<String, dynamic> json) => ClientEvent(
    userRandomId: json["user_random_id"],
  );

  Map<String, dynamic> toJson() => {
    "user_random_id": userRandomId,
  };
}

class EventCoverImage {
  String? code;
  String? name;
  int? screenDisplay;
  JvtFile? jvtFile;

  EventCoverImage({
    this.code,
    this.name,
    this.screenDisplay,
    this.jvtFile,
  });

  factory EventCoverImage.fromJson(Map<String, dynamic> json) => EventCoverImage(
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
