// To parse this JSON data, do
//
//     final photoSelectionConfirmedIndex = photoSelectionConfirmedIndexFromJson(jsonString);

import 'dart:convert';

PhotoSelectionConfirmedIndex photoSelectionConfirmedIndexFromJson(str) =>
    PhotoSelectionConfirmedIndex.fromJson(json.decode(str));

String photoSelectionConfirmedIndexToJson(PhotoSelectionConfirmedIndex data) =>
    json.encode(data.toJson());

class PhotoSelectionConfirmedIndex {
  List<PhotoSelectionImage>? photoSelectionImages;
  dynamic lastUpdatedAt;

  PhotoSelectionConfirmedIndex({
    this.photoSelectionImages,
    this.lastUpdatedAt,
  });

  factory PhotoSelectionConfirmedIndex.fromJson(Map<String, dynamic> json) =>
      PhotoSelectionConfirmedIndex(
        photoSelectionImages: json["photo_selection_images"] == null
            ? []
            : List<PhotoSelectionImage>.from(json["photo_selection_images"]!
                .map((x) => PhotoSelectionImage.fromJson(x))),
        lastUpdatedAt: json["last_updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "photo_selection_images": photoSelectionImages == null
            ? []
            : List<dynamic>.from(photoSelectionImages!.map((x) => x.toJson())),
        "last_updated_at": lastUpdatedAt,
      };
}

class PhotoSelectionImage {
  String? code;
  int? status;
  dynamic comment;
  int? rating;

  PhotoSelectionImage({
    this.code,
    this.status,
    this.comment,
    this.rating,
  });

  factory PhotoSelectionImage.fromJson(Map<String, dynamic> json) =>
      PhotoSelectionImage(
        code: json["code"],
        status: json["status"],
        comment: json["comment"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "comment": comment,
        "rating": rating,
      };
}
