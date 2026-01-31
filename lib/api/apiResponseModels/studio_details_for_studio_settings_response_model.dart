// To parse this JSON data, do
//
//     final studioDetailsForStudioSettingsResponseModel = studioDetailsForStudioSettingsResponseModelFromJson(jsonString);

import 'dart:convert';

StudioDetailsForStudioSettingsResponseModel studioDetailsForStudioSettingsResponseModelFromJson( str) => StudioDetailsForStudioSettingsResponseModel.fromJson(json.decode(str));

String studioDetailsForStudioSettingsResponseModelToJson(StudioDetailsForStudioSettingsResponseModel data) => json.encode(data.toJson());

class StudioDetailsForStudioSettingsResponseModel {
  List<StudioDetail>? studioDetails;

  StudioDetailsForStudioSettingsResponseModel({
    this.studioDetails,
  });

  factory StudioDetailsForStudioSettingsResponseModel.fromJson(Map<String, dynamic> json) => StudioDetailsForStudioSettingsResponseModel(
    studioDetails: json["studio_details"] == null ? [] : List<StudioDetail>.from(json["studio_details"]!.map((x) => StudioDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "studio_details": studioDetails == null ? [] : List<dynamic>.from(studioDetails!.map((x) => x.toJson())),
  };
}

class StudioDetail {
  String? code;
  String? studioUrl;
  String? randomUrl;
  dynamic website;
  dynamic smsName;
  int? studioLanguageId;
  Established? established;
  int? galleryImagesCount;
  dynamic shortName;
  DefaultSettings? defaultSettings;

  StudioDetail({
    this.code,
    this.studioUrl,
    this.randomUrl,
    this.website,
    this.smsName,
    this.studioLanguageId,
    this.established,
    this.galleryImagesCount,
    this.shortName,
    this.defaultSettings,
  });

  factory StudioDetail.fromJson(Map<String, dynamic> json) => StudioDetail(
    code: json["code"],
    studioUrl: json["studio_url"],
    randomUrl: json["random_url"],
    website: json["website"],
    smsName: json["sms_name"],
    studioLanguageId: json["studio_language_id"],
    established: json["established"] == null ? null : Established.fromJson(json["established"]),
    galleryImagesCount: json["gallery_images_count"],
    shortName: json["short_name"],
    defaultSettings: json["default_settings"] == null ? null : DefaultSettings.fromJson(json["default_settings"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "studio_url": studioUrl,
    "random_url": randomUrl,
    "website": website,
    "sms_name": smsName,
    "studio_language_id": studioLanguageId,
    "established": established?.toJson(),
    "gallery_images_count": galleryImagesCount,
    "short_name": shortName,
    "default_settings": defaultSettings?.toJson(),
  };
}

class DefaultSettings {
  int? appTour;
  int? trueCaller;
  int? downloadable;
  int? watermarkTop;
  int? ownPlayStore;
  int? watermarkLeft;
  int? watermarkSize;
  int? doubtImageClear;
  int? hideMediaPhotos;
  int? watermarkOpacity;
  int? albumDownloadable;
  int? downloadWithIcon;
  int? watermarkPosition;
  int? notificationStatus;
  int? photosPrintStatus;
  int? eventviewAppRedirect;
  int? forbiddenAppRedirect;
  int? myPhotosDownloadable;
  int? downloadWithWatermark;
  int? multipleFolderConditions;
  int? showPhotosAsRoundedEdge;
  int? doubtImageClearForEndUser;
  int? downloadAllPhotoselectionImages;
  int? usersAllowedPerAccountInFaceRecognition;

  DefaultSettings({
    this.appTour,
    this.trueCaller,
    this.downloadable,
    this.watermarkTop,
    this.ownPlayStore,
    this.watermarkLeft,
    this.watermarkSize,
    this.doubtImageClear,
    this.hideMediaPhotos,
    this.watermarkOpacity,
    this.albumDownloadable,
    this.downloadWithIcon,
    this.watermarkPosition,
    this.notificationStatus,
    this.photosPrintStatus,
    this.eventviewAppRedirect,
    this.forbiddenAppRedirect,
    this.myPhotosDownloadable,
    this.downloadWithWatermark,
    this.multipleFolderConditions,
    this.showPhotosAsRoundedEdge,
    this.doubtImageClearForEndUser,
    this.downloadAllPhotoselectionImages,
    this.usersAllowedPerAccountInFaceRecognition,
  });

  factory DefaultSettings.fromJson(Map<String, dynamic> json) => DefaultSettings(
    appTour: json["app_tour"],
    trueCaller: json["true_caller"],
    downloadable: json["downloadable"],
    watermarkTop: json["watermark_top"],
    ownPlayStore: json["own_play_store"],
    watermarkLeft: json["watermark_left"],
    watermarkSize: json["watermark_size"],
    doubtImageClear: json["doubt_image_clear"],
    hideMediaPhotos: json["hide_media_photos"],
    watermarkOpacity: json["watermark_opacity"],
    albumDownloadable: json["album_downloadable"],
    downloadWithIcon: json["download_with_icon"],
    watermarkPosition: json["watermark_position"],
    notificationStatus: json["notification_status"],
    photosPrintStatus: json["photos_print_status"],
    eventviewAppRedirect: json["eventview_app_redirect"],
    forbiddenAppRedirect: json["forbidden_app_redirect"],
    myPhotosDownloadable: json["my_photos_downloadable"],
    downloadWithWatermark: json["download_with_watermark"],
    multipleFolderConditions: json["multiple_folder_conditions"],
    showPhotosAsRoundedEdge: json["show_photos_as_rounded_edge"],
    doubtImageClearForEndUser: json["doubt_image_clear_for_end_user"],
    downloadAllPhotoselectionImages: json["download_all_photoselection_images"],
    usersAllowedPerAccountInFaceRecognition: json["users_allowed_per_account_in_face_recognition"],
  );

  Map<String, dynamic> toJson() => {
    "app_tour": appTour,
    "true_caller": trueCaller,
    "downloadable": downloadable,
    "watermark_top": watermarkTop,
    "own_play_store": ownPlayStore,
    "watermark_left": watermarkLeft,
    "watermark_size": watermarkSize,
    "doubt_image_clear": doubtImageClear,
    "hide_media_photos": hideMediaPhotos,
    "watermark_opacity": watermarkOpacity,
    "album_downloadable": albumDownloadable,
    "download_with_icon": downloadWithIcon,
    "watermark_position": watermarkPosition,
    "notification_status": notificationStatus,
    "photos_print_status": photosPrintStatus,
    "eventview_app_redirect": eventviewAppRedirect,
    "forbidden_app_redirect": forbiddenAppRedirect,
    "my_photos_downloadable": myPhotosDownloadable,
    "download_with_watermark": downloadWithWatermark,
    "multiple_folder_conditions": multipleFolderConditions,
    "show_photos_as_rounded_edge": showPhotosAsRoundedEdge,
    "doubt_image_clear_for_end_user": doubtImageClearForEndUser,
    "download_all_photoselection_images": downloadAllPhotoselectionImages,
    "users_allowed_per_account_in_face_recognition": usersAllowedPerAccountInFaceRecognition,
  };
}

class Established {
  String? date;
  String? year;
  String? month;

  Established({
    this.date,
    this.year,
    this.month,
  });

  factory Established.fromJson(Map<String, dynamic> json) => Established(
    date: json["date"],
    year: json["year"],
    month: json["month"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "year": year,
    "month": month,
  };
}
