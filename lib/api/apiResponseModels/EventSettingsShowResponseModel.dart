// To parse this JSON data, do
//
//     final eventSettingsShowResponse = eventSettingsShowResponseFromJson(jsonString);

import 'dart:convert';

EventSettingsShowResponse eventSettingsShowResponseFromJson(str) => EventSettingsShowResponse.fromJson(json.decode(str));

String eventSettingsShowResponseToJson(EventSettingsShowResponse data) => json.encode(data.toJson());

class EventSettingsShowResponse {
  PhotomallEvent? photomallEvent;

  EventSettingsShowResponse({
    this.photomallEvent,
  });

  factory EventSettingsShowResponse.fromJson(Map<String, dynamic> json) => EventSettingsShowResponse(
    photomallEvent: json["Photomall_event"] == null ? null : PhotomallEvent.fromJson(json["Photomall_event"]),
  );

  Map<String, dynamic> toJson() => {
    "Photomall_event": photomallEvent?.toJson(),
  };
}

class PhotomallEvent {
  String? code;
  String? name;
  int? published;
  int? photoselectionDownloadStatus;
  int? photosDownloadStatus;
  int? myPhotosDownloadStatus;
  int? downloadWithIcon;
  int? downloadWithWatermark;
  int? aiEnabled;
  Settings? settings;
  EventPlan? eventPlan;
  StudioPlan? studioPlan;

  PhotomallEvent({
    this.code,
    this.name,
    this.published,
    this.photoselectionDownloadStatus,
    this.photosDownloadStatus,
    this.myPhotosDownloadStatus,
    this.downloadWithIcon,
    this.downloadWithWatermark,
    this.aiEnabled,
    this.settings,
    this.eventPlan,
    this.studioPlan,
  });

  factory PhotomallEvent.fromJson(Map<String, dynamic> json) => PhotomallEvent(
    code: json["code"],
    name: json["name"],
    published: json["published"],
    photoselectionDownloadStatus: json["photoselection_download_status"],
    photosDownloadStatus: json["photos_download_status"],
    myPhotosDownloadStatus: json["my_photos_download_status"],
    downloadWithIcon: json["download_with_icon"],
    downloadWithWatermark: json["download_with_watermark"],
    aiEnabled: json["ai_enabled"],
    settings: json["settings"] == null ? null : Settings.fromJson(json["settings"]),
    eventPlan: json["event_plan"] == null ? null : EventPlan.fromJson(json["event_plan"]),
    studioPlan: json["studio_plan"] == null ? null : StudioPlan.fromJson(json["studio_plan"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "published": published,
    "photoselection_download_status": photoselectionDownloadStatus,
    "photos_download_status": photosDownloadStatus,
    "my_photos_download_status": myPhotosDownloadStatus,
    "download_with_icon": downloadWithIcon,
    "download_with_watermark": downloadWithWatermark,
    "ai_enabled": aiEnabled,
    "settings": settings?.toJson(),
    "event_plan": eventPlan?.toJson(),
    "studio_plan": studioPlan?.toJson(),
  };
}

class EventPlan {
  String? code;
  String? name;
  Attributes? attributes;

  EventPlan({
    this.code,
    this.name,
    this.attributes,
  });

  factory EventPlan.fromJson(Map<String, dynamic> json) => EventPlan(
    code: json["code"],
    name: json["name"],
    attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "attributes": attributes?.toJson(),
  };
}

class Attributes {
  int? price;
  int? aiEnabled;
  int? albumDownload;
  String? eventValidity;
  int? priceWithTax;
  int? notificationStatus;
  String? ePhotobookValidity;
  String? photoAlbumValidity;
  String? eventValidityByDays;
  String? ePhotobookImageCount;
  int? photoAlbumImageCount;
  int? photoSelectionDownload;
  String? photoSelectionValidity;
  int? photoSelectionImageCount;
  String? photoAlbumValidityByDays;
  String? photoSelectionValidityByDays;

  Attributes({
    this.price,
    this.aiEnabled,
    this.albumDownload,
    this.eventValidity,
    this.priceWithTax,
    this.notificationStatus,
    this.ePhotobookValidity,
    this.photoAlbumValidity,
    this.eventValidityByDays,
    this.ePhotobookImageCount,
    this.photoAlbumImageCount,
    this.photoSelectionDownload,
    this.photoSelectionValidity,
    this.photoSelectionImageCount,
    this.photoAlbumValidityByDays,
    this.photoSelectionValidityByDays,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
    price: json["price"],
    aiEnabled: json["ai_enabled"],
    albumDownload: json["album_download"],
    eventValidity: json["event_validity"],
    priceWithTax: json["price_with_tax"],
    notificationStatus: json["notification_status"],
    ePhotobookValidity: json["e_photobook_validity"],
    photoAlbumValidity: json["photo_album_validity"],
    eventValidityByDays: json["event_validity_by_days"],
    ePhotobookImageCount: json["e_photobook_image_count"],
    photoAlbumImageCount: json["photo_album_image_count"],
    photoSelectionDownload: json["photo_selection_download"],
    photoSelectionValidity: json["photo_selection_validity"],
    photoSelectionImageCount: json["photo_selection_image_count"],
    photoAlbumValidityByDays: json["photo_album_validity_by_days"],
    photoSelectionValidityByDays: json["photo_selection_validity_by_days"],
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "ai_enabled": aiEnabled,
    "album_download": albumDownload,
    "event_validity": eventValidity,
    "price_with_tax": priceWithTax,
    "notification_status": notificationStatus,
    "e_photobook_validity": ePhotobookValidity,
    "photo_album_validity": photoAlbumValidity,
    "event_validity_by_days": eventValidityByDays,
    "e_photobook_image_count": ePhotobookImageCount,
    "photo_album_image_count": photoAlbumImageCount,
    "photo_selection_download": photoSelectionDownload,
    "photo_selection_validity": photoSelectionValidity,
    "photo_selection_image_count": photoSelectionImageCount,
    "photo_album_validity_by_days": photoAlbumValidityByDays,
    "photo_selection_validity_by_days": photoSelectionValidityByDays,
  };
}

class Settings {
  String? watermarkSize;
  String? mediaPhotoHide;
  String? aiOrderPriority;
  int? watermarkOpacity;
  String? watermarkPosition;
  String? notificationStatus;
  String? photosPrintStatus;
  int? aiPhotoSelectionPriority;

  Settings({
    this.watermarkSize,
    this.mediaPhotoHide,
    this.aiOrderPriority,
    this.watermarkOpacity,
    this.watermarkPosition,
    this.notificationStatus,
    this.photosPrintStatus,
    this.aiPhotoSelectionPriority,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    watermarkSize: json["watermark_size"],
    mediaPhotoHide: json["media_photo_hide"],
    aiOrderPriority: json["ai_order_priority"],
    watermarkOpacity: json["watermark_opacity"],
    watermarkPosition: json["watermark_position"],
    notificationStatus: json["notification_status"],
    photosPrintStatus: json["photos_print_status"],
    aiPhotoSelectionPriority: json["ai_photo_selection_priority"],
  );

  Map<String, dynamic> toJson() => {
    "watermark_size": watermarkSize,
    "media_photo_hide": mediaPhotoHide,
    "ai_order_priority": aiOrderPriority,
    "watermark_opacity": watermarkOpacity,
    "watermark_position": watermarkPosition,
    "notification_status": notificationStatus,
    "photos_print_status": photosPrintStatus,
    "ai_photo_selection_priority": aiPhotoSelectionPriority,
  };
}

class StudioPlan {
  String? code;
  int? whatsappMessageCustomize;

  StudioPlan({
    this.code,
    this.whatsappMessageCustomize,
  });

  factory StudioPlan.fromJson(Map<String, dynamic> json) => StudioPlan(
    code: json["code"],
    whatsappMessageCustomize: json["whatsapp_message_customize"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "whatsapp_message_customize": whatsappMessageCustomize,
  };
}
