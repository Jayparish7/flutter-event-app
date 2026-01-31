// To parse this JSON data, do
//
//     final transporterResponse = transporterResponseFromJson(jsonString);

import 'dart:convert';

TransporterResponse transporterResponseFromJson(str) =>
    TransporterResponse.fromJson(json.decode(str));

String transporterResponseToJson(TransporterResponse data) =>
    json.encode(data.toJson());

class TransporterResponse {
  List<StudiosDatum>? studiosData;

  TransporterResponse({
    this.studiosData,
  });

  factory TransporterResponse.fromJson(Map<String, dynamic> json) =>
      TransporterResponse(
        studiosData: json["studios_data"] == null
            ? []
            : List<StudiosDatum>.from(
                json["studios_data"]!.map((x) => StudiosDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "studios_data": studiosData == null
            ? []
            : List<dynamic>.from(studiosData!.map((x) => x.toJson())),
      };
}

class StudiosDatum {
  String? code;
  int? updateRequired;
  int? lastUpdatedAt;
  Data? data;

  StudiosDatum({
    this.code,
    this.updateRequired,
    this.lastUpdatedAt,
    this.data,
  });

  factory StudiosDatum.fromJson(Map<String, dynamic> json) => StudiosDatum(
        code: json["code"],
        updateRequired: json["update_required"],
        lastUpdatedAt: json["last_updated_at"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "update_required": updateRequired,
        "last_updated_at": lastUpdatedAt,
        "data": data?.toJson(),
      };
}

class Data {
  String? name;
  String? code;
  String? domainUrl;
  String? playStoreUrl;
  String? shortUrl;
  String? ptmlDomain;
  String? description;
  List<Package>? packages;
  String? website;
  String? publicStoragePath;
  String? privateStoragePath;
  List<JvtFileConnector>? jvtFileConnectors;
  List<ContactPoint>? contactPoints;
  List<SocialProfile>? socialProfiles;
  Carousel? carousel;
  List<String>? events;

  List<String>? photoselections;
  int? maximumScreenDisplay;
  List<EventCategory>? eventCategories;
  int? lastUpdatedAt;
  String? whatsapp;
  Type? type;
  Country? country;
  String? usersAllowedPerAccountInFaceRecognition;
  int? faceRecognitionUsersAllowedPerAccount;
  int? showPhotosAsRoundedEdge;
  int? trueCaller;
  int? ownPlayStore;
  List<EventCategory>? relationship;
  List<GoogleReview>? googleReviews;
  Plan? plan;

  Data({
    this.name,
    this.code,
    this.domainUrl,
    this.playStoreUrl,
    this.shortUrl,
    this.ptmlDomain,
    this.description,
    this.packages,
    this.website,
    this.publicStoragePath,
    this.privateStoragePath,
    this.jvtFileConnectors,
    this.contactPoints,
    this.socialProfiles,
    this.carousel,
    this.events,
    this.photoselections,
    this.maximumScreenDisplay,
    this.eventCategories,
    this.lastUpdatedAt,
    this.whatsapp,
    this.type,
    this.country,
    this.usersAllowedPerAccountInFaceRecognition,
    this.faceRecognitionUsersAllowedPerAccount,
    this.showPhotosAsRoundedEdge,
    this.trueCaller,
    this.ownPlayStore,
    this.relationship,
    this.googleReviews,
    this.plan,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        code: json["code"],
        domainUrl: json["domain_url"],
        playStoreUrl: json["play_store_url"],
        shortUrl: json["short_url"],
        ptmlDomain: json["ptml_domain"],
        description: json["description"],
        packages: json["packages"] == null
            ? []
            : List<Package>.from(
                json["packages"]!.map((x) => Package.fromJson(x))),
        website: json["website"],
        publicStoragePath: json["public_storage_path"],
        privateStoragePath: json["private_storage_path"],
        jvtFileConnectors: json["jvt_file_connectors"] == null
            ? []
            : List<JvtFileConnector>.from(json["jvt_file_connectors"]!
                .map((x) => JvtFileConnector.fromJson(x))),
        contactPoints: json["contact_points"] == null
            ? []
            : List<ContactPoint>.from(
                json["contact_points"]!.map((x) => ContactPoint.fromJson(x))),
        socialProfiles: json["social_profiles"] == null
            ? []
            : List<SocialProfile>.from(
                json["social_profiles"]!.map((x) => SocialProfile.fromJson(x))),
        carousel: json["carousel"] == null
            ? null
            : Carousel.fromJson(json["carousel"]),
        events: json["events"] == null
            ? []
            : List<String>.from(json["events"]!.map((x) => x)),
        photoselections: json["photoselections"] == null
            ? []
            : List<String>.from(json["photoselections"]!.map((x) => x)),
        maximumScreenDisplay: json["maximum_screen_display"],
        eventCategories: json["event_categories"] == null
            ? []
            : List<EventCategory>.from(json["event_categories"]!
                .map((x) => EventCategory.fromJson(x))),
        lastUpdatedAt: json["last_updated_at"],
        whatsapp: json["whatsapp"],
        type: json["type"] == null ? null : Type.fromJson(json["type"]),
        country:
            json["country"] == null ? null : Country.fromJson(json["country"]),
        usersAllowedPerAccountInFaceRecognition:
            json["users_allowed_per_account_in_face_recognition"],
        faceRecognitionUsersAllowedPerAccount:
            json["face_recognition_users_allowed_per_account"],
        showPhotosAsRoundedEdge: json["show_photos_as_rounded_edge"],
        trueCaller: json["true_caller"],
        ownPlayStore: json["own_play_store"],
        relationship: json["relationship"] == null
            ? []
            : List<EventCategory>.from(
                json["relationship"]!.map((x) => EventCategory.fromJson(x))),
        googleReviews: json["google_reviews"] == null
            ? []
            : List<GoogleReview>.from(
                json["google_reviews"]!.map((x) => GoogleReview.fromJson(x))),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "code": code,
        "domain_url": domainUrl,
        "play_store_url": playStoreUrl,
        "short_url": shortUrl,
        "ptml_domain": ptmlDomain,
        "description": description,
        "packages": packages == null
            ? []
            : List<dynamic>.from(packages!.map((x) => x.toJson())),
        "website": website,
        "public_storage_path": publicStoragePath,
        "private_storage_path": privateStoragePath,
        "jvt_file_connectors": jvtFileConnectors == null
            ? []
            : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
        "contact_points": contactPoints == null
            ? []
            : List<dynamic>.from(contactPoints!.map((x) => x.toJson())),
        "social_profiles": socialProfiles == null
            ? []
            : List<dynamic>.from(socialProfiles!.map((x) => x.toJson())),
        "carousel": carousel?.toJson(),
        "events":
            events == null ? [] : List<dynamic>.from(events!.map((x) => x)),
        "photoselections": photoselections == null
            ? []
            : List<dynamic>.from(photoselections!.map((x) => x)),
        "maximum_screen_display": maximumScreenDisplay,
        "event_categories": eventCategories == null
            ? []
            : List<dynamic>.from(eventCategories!.map((x) => x.toJson())),
        "last_updated_at": lastUpdatedAt,
        "whatsapp": whatsapp,
        "type": type?.toJson(),
        "country": country?.toJson(),
        "users_allowed_per_account_in_face_recognition":
            usersAllowedPerAccountInFaceRecognition,
        "face_recognition_users_allowed_per_account":
            faceRecognitionUsersAllowedPerAccount,
        "show_photos_as_rounded_edge": showPhotosAsRoundedEdge,
        "true_caller": trueCaller,
        "own_play_store": ownPlayStore,
        "relationship": relationship == null
            ? []
            : List<dynamic>.from(relationship!.map((x) => x.toJson())),
        "google_reviews": googleReviews == null
            ? []
            : List<dynamic>.from(googleReviews!.map((x) => x.toJson())),
        "plan": plan?.toJson(),
      };
}

class Carousel {
  String? code;
  int? interval;
  int? lastUpdatedAt;
  List<Resolution>? resolutions;
  List<CarouselProperty>? carouselProperties;

  Carousel({
    this.code,
    this.interval,
    this.lastUpdatedAt,
    this.resolutions,
    this.carouselProperties,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) => Carousel(
        code: json["code"],
        interval: json["interval"],
        lastUpdatedAt: json["last_updated_at"],
        resolutions: json["resolutions"] == null
            ? []
            : List<Resolution>.from(
                json["resolutions"]!.map((x) => Resolution.fromJson(x))),
        carouselProperties: json["carousel_properties"] == null
            ? []
            : List<CarouselProperty>.from(json["carousel_properties"]!
                .map((x) => CarouselProperty.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "interval": interval,
        "last_updated_at": lastUpdatedAt,
        "resolutions": resolutions == null
            ? []
            : List<dynamic>.from(resolutions!.map((x) => x.toJson())),
        "carousel_properties": carouselProperties == null
            ? []
            : List<dynamic>.from(carouselProperties!.map((x) => x.toJson())),
      };
}

class CarouselProperty {
  String? code;
  dynamic ableType;
  dynamic ableCode;
  int? priority;
  List<JvtFileConnector>? jvtFileConnectors;

  CarouselProperty({
    this.code,
    this.ableType,
    this.ableCode,
    this.priority,
    this.jvtFileConnectors,
  });

  factory CarouselProperty.fromJson(Map<String, dynamic> json) =>
      CarouselProperty(
        code: json["code"],
        ableType: json["able_type"],
        ableCode: json["able_code"],
        priority: json["priority"],
        jvtFileConnectors: json["jvt_file_connectors"] == null
            ? []
            : List<JvtFileConnector>.from(json["jvt_file_connectors"]!
                .map((x) => JvtFileConnector.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "able_type": ableType,
        "able_code": ableCode,
        "priority": priority,
        "jvt_file_connectors": jvtFileConnectors == null
            ? []
            : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
      };
}

class JvtFileConnector {
  String? code;
  String? name;
  int? screenDisplay;
  JvtFile? jvtFile;

  JvtFileConnector({
    this.code,
    this.name,
    this.screenDisplay,
    this.jvtFile,
  });

  factory JvtFileConnector.fromJson(Map<String, dynamic> json) =>
      JvtFileConnector(
        code: json["code"],
        name: json["name"],
        screenDisplay: json["screen_display"],
        jvtFile: json["jvt_file"] == null
            ? null
            : JvtFile.fromJson(json["jvt_file"]),
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
  Extension? extension;

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
        extension: extensionValues.map[json["extension"]]!,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "mode": mode,
        "size": size,
        "extension": extensionValues.reverse[extension],
      };
}

enum Extension { JPEG, JPG, PNG }

final extensionValues = EnumValues(
    {".jpeg": Extension.JPEG, ".jpg": Extension.JPG, ".png": Extension.PNG});

class Resolution {
  int? screenDisplay;
  int? height;
  int? width;

  Resolution({
    this.screenDisplay,
    this.height,
    this.width,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) => Resolution(
        screenDisplay: json["screen_display"],
        height: json["height"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "screen_display": screenDisplay,
        "height": height,
        "width": width,
      };
}

class ContactPoint {
  String? name;
  Address? address;
  List<Phone>? phones;
  List<Email>? emails;

  ContactPoint({
    this.name,
    this.address,
    this.phones,
    this.emails,
  });

  factory ContactPoint.fromJson(Map<String, dynamic> json) => ContactPoint(
        name: json["name"],
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        phones: json["phones"] == null
            ? []
            : List<Phone>.from(json["phones"]!.map((x) => Phone.fromJson(x))),
        emails: json["emails"] == null
            ? []
            : List<Email>.from(json["emails"]!.map((x) => Email.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address?.toJson(),
        "phones": phones == null
            ? []
            : List<dynamic>.from(phones!.map((x) => x.toJson())),
        "emails": emails == null
            ? []
            : List<dynamic>.from(emails!.map((x) => x.toJson())),
      };
}

class Address {
  String? code;
  String? street;
  String? locality;
  String? district;
  String? state;
  String? country;
  String? pincode;
  String? latitude;
  String? longitude;

  Address({
    this.code,
    this.street,
    this.locality,
    this.district,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        code: json["code"],
        street: json["street"],
        locality: json["locality"],
        district: json["district"],
        state: json["state"],
        country: json["country"],
        pincode: json["pincode"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "street": street,
        "locality": locality,
        "district": district,
        "state": state,
        "country": country,
        "pincode": pincode,
        "latitude": latitude,
        "longitude": longitude,
      };
}

class Email {
  int? id;
  String? address;

  Email({
    this.id,
    this.address,
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
        id: json["id"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "address": address,
      };
}

class Phone {
  int? id;
  String? phoneNumber;

  Phone({
    this.id,
    this.phoneNumber,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        id: json["id"],
        phoneNumber: json["phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone_number": phoneNumber,
      };
}

class Country {
  int? id;
  String? name;
  String? code;
  String? shortCode;

  Country({
    this.id,
    this.name,
    this.code,
    this.shortCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        shortCode: json["short_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "short_code": shortCode,
      };
}

class EventCategory {
  String? code;
  String? name;

  EventCategory({
    this.code,
    this.name,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) => EventCategory(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}

class GoogleReview {
  String? code;
  String? phone;
  int? rating;
  List<Review>? reviews;

  GoogleReview({
    this.code,
    this.phone,
    this.rating,
    this.reviews,
  });

  factory GoogleReview.fromJson(Map<String, dynamic> json) => GoogleReview(
        code: json["code"],
        phone: json["phone"],
        rating: json["rating"],
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                json["reviews"]!.map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "phone": phone,
        "rating": rating,
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
      };
}

class Review {
  String? code;
  String? authorName;
  String? authorUrl;
  String? profilePhotoUrl;
  int? rating;
  DateTime? time;
  String? review;

  Review({
    this.code,
    this.authorName,
    this.authorUrl,
    this.profilePhotoUrl,
    this.rating,
    this.time,
    this.review,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        code: json["code"],
        authorName: json["author_name"],
        authorUrl: json["author_url"],
        profilePhotoUrl: json["profile_photo_url"],
        rating: json["rating"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        review: json["review"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "author_name": authorName,
        "author_url": authorUrl,
        "profile_photo_url": profilePhotoUrl,
        "rating": rating,
        "time": time?.toIso8601String(),
        "review": review,
      };
}

class Package {
  String? code;
  String? name;
  int? published;
  int? priorityScore;
  List<JvtFileConnector>? jvtFileConnectors;
  String? description;
  int? price;
  Discount? discount;
  int? lastUpdatedAt;
  List<PackageValue>? packageValues;

  Package({
    this.code,
    this.name,
    this.published,
    this.priorityScore,
    this.jvtFileConnectors,
    this.description,
    this.price,
    this.discount,
    this.lastUpdatedAt,
    this.packageValues,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        code: json["code"],
        name: json["name"],
        published: json["published"],
        priorityScore: json["priority_score"],
        jvtFileConnectors: json["jvt_file_connectors"] == null
            ? []
            : List<JvtFileConnector>.from(json["jvt_file_connectors"]!
                .map((x) => JvtFileConnector.fromJson(x))),
        description: json["description"],
        price: json["price"],
        discount: json["discount"] == null
            ? null
            : Discount.fromJson(json["discount"]),
        lastUpdatedAt: json["last_updated_at"],
        packageValues: json["package_values"] == null
            ? []
            : List<PackageValue>.from(
                json["package_values"]!.map((x) => PackageValue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "published": published,
        "priority_score": priorityScore,
        "jvt_file_connectors": jvtFileConnectors == null
            ? []
            : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
        "description": description,
        "price": price,
        "discount": discount?.toJson(),
        "last_updated_at": lastUpdatedAt,
        "package_values": packageValues == null
            ? []
            : List<dynamic>.from(packageValues!.map((x) => x.toJson())),
      };
}

class Discount {
  int? value;
  int? termsOf;

  Discount({
    this.value,
    this.termsOf,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
        value: json["value"],
        termsOf: json["terms_of"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "terms_of": termsOf,
      };
}

class PackageValue {
  String? code;
  String? key;
  String? value;
  List<JvtFileConnector>? jvtFileConnectors;

  PackageValue({
    this.code,
    this.key,
    this.value,
    this.jvtFileConnectors,
  });

  factory PackageValue.fromJson(Map<String, dynamic> json) => PackageValue(
        code: json["code"],
        key: json["key"],
        value: json["value"],
        jvtFileConnectors: json["jvt_file_connectors"] == null
            ? []
            : List<JvtFileConnector>.from(json["jvt_file_connectors"]!
                .map((x) => JvtFileConnector.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "key": key,
        "value": value,
        "jvt_file_connectors": jvtFileConnectors == null
            ? []
            : List<dynamic>.from(jvtFileConnectors!.map((x) => x.toJson())),
      };
}

class Plan {
  String? code;
  int? photoSelectionDownloadStatus;
  int? photosDownloadStatus;
  int? galleryImagesCount;

  Plan({
    this.code,
    this.photoSelectionDownloadStatus,
    this.photosDownloadStatus,
    this.galleryImagesCount,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        code: json["code"],
        photoSelectionDownloadStatus: json["photo_selection_download_status"],
        photosDownloadStatus: json["photos_download_status"],
        galleryImagesCount: json["gallery_images_count"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "photo_selection_download_status": photoSelectionDownloadStatus,
        "photos_download_status": photosDownloadStatus,
        "gallery_images_count": galleryImagesCount,
      };
}

class ScreenDisplay {
  List<int>? screenDisplay1;
  List<int>? screenDisplay2;
  List<int>? screenDisplay3;
  List<int>? screenDisplay4;

  ScreenDisplay({
    this.screenDisplay1,
    this.screenDisplay2,
    this.screenDisplay3,
    this.screenDisplay4,
  });

  factory ScreenDisplay.fromJson(Map<String, dynamic> json) => ScreenDisplay(
        screenDisplay1: json["screen_display_1"] == null
            ? []
            : List<int>.from(json["screen_display_1"]!.map((x) => x)),
        screenDisplay2: json["screen_display_2"] == null
            ? []
            : List<int>.from(json["screen_display_2"]!.map((x) => x)),
        screenDisplay3: json["screen_display_3"] == null
            ? []
            : List<int>.from(json["screen_display_3"]!.map((x) => x)),
        screenDisplay4: json["screen_display_4"] == null
            ? []
            : List<int>.from(json["screen_display_4"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "screen_display_1": screenDisplay1 == null
            ? []
            : List<dynamic>.from(screenDisplay1!.map((x) => x)),
        "screen_display_2": screenDisplay2 == null
            ? []
            : List<dynamic>.from(screenDisplay2!.map((x) => x)),
        "screen_display_3": screenDisplay3 == null
            ? []
            : List<dynamic>.from(screenDisplay3!.map((x) => x)),
        "screen_display_4": screenDisplay4 == null
            ? []
            : List<dynamic>.from(screenDisplay4!.map((x) => x)),
      };
}

class SocialProfile {
  String? code;
  int? type;
  String? url;
  String? baseUrl;

  SocialProfile({
    this.code,
    this.type,
    this.url,
    this.baseUrl,
  });

  factory SocialProfile.fromJson(Map<String, dynamic> json) => SocialProfile(
        code: json["code"],
        type: json["type"],
        url: json["url"],
        baseUrl: json["base_url"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "type": type,
        "url": url,
        "base_url": baseUrl,
      };
}

class Type {
  String? name;
  int? status;
  String? code;

  Type({
    this.name,
    this.status,
    this.code,
  });

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        name: json["name"],
        status: json["status"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "code": code,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

ScreenDisplay screenDisplayAsset = ScreenDisplay(
    screenDisplay1: [240, 135],
    screenDisplay2: [1920, 1080],
    screenDisplay3: [2560, 1440],
    screenDisplay4: [5120, 2880]);
