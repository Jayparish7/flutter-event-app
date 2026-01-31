// To parse this JSON data, do
//
//     final studioUsersSearchResponseModel = studioUsersSearchResponseModelFromJson(jsonString);

import 'dart:convert';

StudioUsersSearchResponseModel studioUsersSearchResponseModelFromJson(str) => StudioUsersSearchResponseModel.fromJson(json.decode(str));

String studioUsersSearchResponseModelToJson(StudioUsersSearchResponseModel data) => json.encode(data.toJson());

class StudioUsersSearchResponseModel {
  List<StudioUser>? studioUsers;

  StudioUsersSearchResponseModel({
    this.studioUsers,
  });

  factory StudioUsersSearchResponseModel.fromJson(Map<String, dynamic> json) => StudioUsersSearchResponseModel(
    studioUsers: json["studio_users"] == null ? [] : List<StudioUser>.from(json["studio_users"]!.map((x) => StudioUser.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "studio_users": studioUsers == null ? [] : List<dynamic>.from(studioUsers!.map((x) => x.toJson())),
  };
}

class StudioUser {
  int? studioUserId;
  String? userRandomId;
  String? name;
  List<Phone>? phones;
  List<dynamic>? emails;

  StudioUser({
    this.studioUserId,
    this.userRandomId,
    this.name,
    this.phones,
    this.emails,
  });

  factory StudioUser.fromJson(Map<String, dynamic> json) => StudioUser(
    studioUserId: json["studio_user_id"],
    userRandomId: json["user_random_id"],
    name: json["name"],
    phones: json["phones"] == null ? [] : List<Phone>.from(json["phones"]!.map((x) => Phone.fromJson(x))),
    emails: json["emails"] == null ? [] : List<dynamic>.from(json["emails"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "studio_user_id": studioUserId,
    "user_random_id": userRandomId,
    "name": name,
    "phones": phones == null ? [] : List<dynamic>.from(phones!.map((x) => x.toJson())),
    "emails": emails == null ? [] : List<dynamic>.from(emails!.map((x) => x)),
  };
}

class Phone {
  int? countryId;
  String? phoneNumber;

  Phone({
    this.countryId,
    this.phoneNumber,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
    countryId: json["country_id"],
    phoneNumber: json["phone_number"],
  );

  Map<String, dynamic> toJson() => {
    "country_id": countryId,
    "phone_number": phoneNumber,
  };
}
