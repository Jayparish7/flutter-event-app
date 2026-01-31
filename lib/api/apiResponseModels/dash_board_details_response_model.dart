// To parse this JSON data, do
//
//     final dashBoardDetailsResponseModel = dashBoardDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

DashBoardDetailsResponseModel dashBoardDetailsResponseModelFromJson(str) => DashBoardDetailsResponseModel.fromJson(json.decode(str));

String dashBoardDetailsResponseModelToJson(DashBoardDetailsResponseModel data) => json.encode(data.toJson());

class DashBoardDetailsResponseModel {
  Studio? studio;

  DashBoardDetailsResponseModel({
    this.studio,
  });

  factory DashBoardDetailsResponseModel.fromJson(Map<String, dynamic> json) => DashBoardDetailsResponseModel(
    studio: json["studio"] == null ? null : Studio.fromJson(json["studio"]),
  );

  Map<String, dynamic> toJson() => {
    "studio": studio?.toJson(),
  };
}

class Studio {
  int? usersCount;
  int? eventsCount;
  int? eventWithPhotoSelectionsCount;
  int? confirmedPhotoselections;
  int? unconfirmedPhotoselections;
  int? eventsWithEAlbumCount;
  int? eventsWithPhotosCount;
  int? eventsWithVideosCount;

  Studio({
    this.usersCount,
    this.eventsCount,
    this.eventWithPhotoSelectionsCount,
    this.confirmedPhotoselections,
    this.unconfirmedPhotoselections,
    this.eventsWithEAlbumCount,
    this.eventsWithPhotosCount,
    this.eventsWithVideosCount,
  });

  factory Studio.fromJson(Map<String, dynamic> json) => Studio(
    usersCount: json["users_count"],
    eventsCount: json["events_count"],
    eventWithPhotoSelectionsCount: json["event_with_photo_selections_count"],
    confirmedPhotoselections: json["confirmed_photoselections"],
    unconfirmedPhotoselections: json["unconfirmed_photoselections"],
    eventsWithEAlbumCount: json["events_with_e_album_count"],
    eventsWithPhotosCount: json["events_with_photos_count"],
    eventsWithVideosCount: json["events_with_videos_count"],
  );

  Map<String, dynamic> toJson() => {
    "users_count": usersCount,
    "events_count": eventsCount,
    "event_with_photo_selections_count": eventWithPhotoSelectionsCount,
    "confirmed_photoselections": confirmedPhotoselections,
    "unconfirmed_photoselections": unconfirmedPhotoselections,
    "events_with_e_album_count": eventsWithEAlbumCount,
    "events_with_photos_count": eventsWithPhotosCount,
    "events_with_videos_count": eventsWithVideosCount,
  };
}
