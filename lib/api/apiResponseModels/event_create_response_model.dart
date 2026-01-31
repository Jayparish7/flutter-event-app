// To parse this JSON data, do
//
//     final eventCreateResponseModel = eventCreateResponseModelFromJson(jsonString);

import 'dart:convert';

EventCreateResponseModel eventCreateResponseModelFromJson(str) => EventCreateResponseModel.fromJson(json.decode(str));

String eventCreateResponseModelToJson(EventCreateResponseModel data) => json.encode(data.toJson());

class EventCreateResponseModel {
  StudioPlan? studioPlan;

  EventCreateResponseModel({
    this.studioPlan,
  });

  factory EventCreateResponseModel.fromJson(Map<String, dynamic> json) => EventCreateResponseModel(
    studioPlan: json["studio_plan"] == null ? null : StudioPlan.fromJson(json["studio_plan"]),
  );

  Map<String, dynamic> toJson() => {
    "studio_plan": studioPlan?.toJson(),
  };
}

class StudioPlan {
  int? id;
  int? planId;
  int? studioId;
  String? code;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? expireAt;
  Plan? plan;

  StudioPlan({
    this.id,
    this.planId,
    this.studioId,
    this.code,
    this.createdAt,
    this.updatedAt,
    this.expireAt,
    this.plan,
  });

  factory StudioPlan.fromJson(Map<String, dynamic> json) => StudioPlan(
    id: json["id"],
    planId: json["plan_id"],
    studioId: json["studio_id"],
    code: json["code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    expireAt: json["expire_at"] == null ? null : DateTime.parse(json["expire_at"]),
    plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "plan_id": planId,
    "studio_id": studioId,
    "code": code,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "expire_at": expireAt?.toIso8601String(),
    "plan": plan?.toJson(),
  };
}

class Plan {
  int? id;
  String? name;
  int? price;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? code;
  int? status;
  DateTime? dateSince;
  dynamic dateTo;
  int? maximumScreenDisplay;
  int? galleryImagesCount;
  int? downloadStatus;
  int? photosDownloadStatus;
  int? validityByAmount;
  int? validityByAmountPerDay;
  int? notificationStatus;
  int? whatsappMessageCustomize;
  int? amountDebitForOneWhatsappMessage;
  List<PlanEventPlan>? planEventPlans;

  Plan({
    this.id,
    this.name,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.code,
    this.status,
    this.dateSince,
    this.dateTo,
    this.maximumScreenDisplay,
    this.galleryImagesCount,
    this.downloadStatus,
    this.photosDownloadStatus,
    this.validityByAmount,
    this.validityByAmountPerDay,
    this.notificationStatus,
    this.whatsappMessageCustomize,
    this.amountDebitForOneWhatsappMessage,
    this.planEventPlans,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    code: json["code"],
    status: json["status"],
    dateSince: json["date_since"] == null ? null : DateTime.parse(json["date_since"]),
    dateTo: json["date_to"],
    maximumScreenDisplay: json["maximum_screen_display"],
    galleryImagesCount: json["gallery_images_count"],
    downloadStatus: json["download_status"],
    photosDownloadStatus: json["photos_download_status"],
    validityByAmount: json["validity_by_amount"],
    validityByAmountPerDay: json["validity_by_amount_per_day"],
    notificationStatus: json["notification_status"],
    whatsappMessageCustomize: json["whatsapp_message_customize"],
    amountDebitForOneWhatsappMessage: json["amount_debit_for_one_whatsapp_message"],
    planEventPlans: json["plan_event_plans"] == null ? [] : List<PlanEventPlan>.from(json["plan_event_plans"]!.map((x) => PlanEventPlan.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "code": code,
    "status": status,
    "date_since": dateSince?.toIso8601String(),
    "date_to": dateTo,
    "maximum_screen_display": maximumScreenDisplay,
    "gallery_images_count": galleryImagesCount,
    "download_status": downloadStatus,
    "photos_download_status": photosDownloadStatus,
    "validity_by_amount": validityByAmount,
    "validity_by_amount_per_day": validityByAmountPerDay,
    "notification_status": notificationStatus,
    "whatsapp_message_customize": whatsappMessageCustomize,
    "amount_debit_for_one_whatsapp_message": amountDebitForOneWhatsappMessage,
    "plan_event_plans": planEventPlans == null ? [] : List<dynamic>.from(planEventPlans!.map((x) => x.toJson())),
  };
}

  class PlanEventPlan {
    int? id;
    int? planId;
    int? eventPlanId;
    int? priorityScore;
    String? code;
    DateTime? createdAt;
    DateTime? updatedAt;
    EventPlan? eventPlan;

    PlanEventPlan({
      this.id,
      this.planId,
      this.eventPlanId,
      this.priorityScore,
      this.code,
      this.createdAt,
      this.updatedAt,
      this.eventPlan,
    });

  factory PlanEventPlan.fromJson(Map<String, dynamic> json) => PlanEventPlan(
    id: json["id"],
    planId: json["plan_id"],
    eventPlanId: json["event_plan_id"],
    priorityScore: json["priority_score"],
    code: json["code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    eventPlan: json["event_plan"] == null ? null : EventPlan.fromJson(json["event_plan"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "plan_id": planId,
    "event_plan_id": eventPlanId,
    "priority_score": priorityScore,
    "code": code,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "event_plan": eventPlan?.toJson(),
  };
}

class EventPlan {
  int? id;
  String? name;
  Attributes? attributes;
  int? status;
  String? code;
  DateTime? createdAt;
  DateTime? updatedAt;

  EventPlan({
    this.id,
    this.name,
    this.attributes,
    this.status,
    this.code,
    this.createdAt,
    this.updatedAt,
  });

  factory EventPlan.fromJson(Map<String, dynamic> json) => EventPlan(
    id: json["id"],
    name: json["name"],
    attributes: json["attributes"] == null ? null : Attributes.fromJson(json["attributes"]),
    status: json["status"],
    code: json["code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "attributes": attributes?.toJson(),
    "status": status,
    "code": code,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
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
  dynamic photoAlbumImageCount;
  int? photoSelectionDownload;
  String? photoSelectionValidity;
  dynamic photoSelectionImageCount;
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
