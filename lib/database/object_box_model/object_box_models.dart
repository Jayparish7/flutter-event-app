import 'dart:typed_data';

import 'package:objectbox/objectbox.dart';

@Entity()
class PhotomallStudioInfo {
  @Id()
  int id = 0; // Auto-increment primary key (required by ObjectBox)

  @Unique()
  String code;

  String value;
  String role;

  int lastUpdatedAt;

  PhotomallStudioInfo({
    this.id = 0,
    required this.code,
    required this.value,
    required this.role,
    required this.lastUpdatedAt,
  });
}

@Entity()
class Events {
  @Id()
  int id = 0;
  @Unique()
  String code;
  String studioCode;
  String name;
  String categoryName;
  bool published;
  int lastUpdatedAt;
  String coverImage;
  String userName;
  int screenDisplay;
  int pageNumber;
  DateTime createdAt;

  Events({
    this.id = 0,
    required this.code,
    required this.studioCode,
    required this.name,
    required this.categoryName,
    required this.published,
    required this.lastUpdatedAt,
    required this.coverImage,
    required this.userName,
    required this.screenDisplay,
    required this.pageNumber,
    required this.createdAt,
  });
}

@Entity()
class Album {
  @Id()
  int id;

  @Unique()
  String code;

  String? name;
  String? size;
  String? path;
  int type;
  String eventCode;
  int lastUpdatedAt;
  int orderLastUpdatedAt;
  String? deviceId;
  int? filesCount;
  int? imagesCount;
  String? directoryModifiedTime;
  int? uploadStatus;

  Album({
    this.id = 0,
    required this.code,
    this.name,
    this.size,
    this.path,
    required this.type,
    required this.eventCode,
    required this.lastUpdatedAt,
    required this.orderLastUpdatedAt,
    this.deviceId,
    this.filesCount,
    this.imagesCount,
    this.directoryModifiedTime,
    this.uploadStatus,
  });
}

@Entity()
class Folder {
  @Id()
  int id = 0;

  @Unique()
  String code;

  String eventCode;

  String? parentCode;

  String name;

  String? path;

  bool sync;

  int lastUpdatedAt;

  String? deviceId;

  String? segregationPath;

  String? customSegregationPath;

  String? segregationFormat;

  int? filesCount;

  int? uploadStatus;

  Folder({
    this.id = 0,
    required this.code,
    required this.eventCode,
    this.parentCode,
    required this.name,
    this.path,
    this.sync = false,
    required this.lastUpdatedAt,
    this.deviceId,
    this.segregationPath,
    this.customSegregationPath,
    this.segregationFormat,
    this.filesCount,
    this.uploadStatus,
  });
}

@Entity()
class Notification {
  @Id()
  int id;

  String? notification; // notification_code
  String? eventCode; // event_code
  String? notificationData; // notification_data
  bool readStatus;
  bool confirmStatus;
  DateTime? createdAt;

  Notification({
    this.id = 0,
    this.notification,
    this.eventCode,
    this.notificationData,
    this.readStatus = false,
    this.confirmStatus = true,
    this.createdAt,
  });
}

@Entity()
class OrderImage {
  @Id()
  int id = 0;

  String? eventCode;
  String? code;
  String albumCode;
  String? name;
  String? path;

  bool? uploaded;
  String? sha256;
  String? md5hash;
  String? preSignedURlCode;

  String? ratio;
  String? screenDisplay2ratio;
  String? screenDisplay2ImageUrl;
  String? screenDisplay2Md5hash;
  String? screenDisplay2PreSignedURlCode;
  String? preSignedURl;
  String? screenDisplay2PreSignedURl;

  int? compressionStatus;
  int? uploadStatus;
  @Property(type: PropertyType.byteVector)
  Uint8List? imageBytes;
  @Property(type: PropertyType.byteVector)
  Uint8List? screenDisplay2imageBytes;

  OrderImage(
      {this.id = 0,
      this.eventCode,
      this.code,
      required this.albumCode,
      this.name,
      this.path,
      this.uploaded = false,
      this.sha256,
      this.md5hash,
      this.preSignedURlCode,
      this.ratio,
      this.screenDisplay2ImageUrl,
      this.screenDisplay2Md5hash,
      this.screenDisplay2PreSignedURlCode,
      this.compressionStatus,
      this.preSignedURl,
      this.screenDisplay2PreSignedURl,
      this.screenDisplay2ratio,
      this.imageBytes,
      this.screenDisplay2imageBytes,
      this.uploadStatus});
}

@Entity()
class PhotoSelectionImage {
  @Id()
  int id = 0;

  String? eventCode;
  String? code;
  String? folderCode;
  String? name;
  String? path;

  bool? uploaded = false;
  int lastUpdatedAt;

  String? sha256;
  String? ratio;
  String? md5hash;
  String? preSignedURlCode;
  String? preSignedURl;
  @Property(type: PropertyType.byteVector)
  Uint8List? imageBytes;
  int? uploadStatus;
  int? compressionStatus;

  PhotoSelectionImage(
      {this.id = 0,
      this.eventCode,
      this.code,
      this.folderCode,
      this.name,
      this.path,
      this.uploaded = false,
      required this.lastUpdatedAt,
      this.sha256,
      this.md5hash,
      this.preSignedURlCode,
      this.preSignedURl,
      this.ratio,
      this.imageBytes,
      this.uploadStatus,
      this.compressionStatus});
}

@Entity()
class PhotoSelectionImageCondition {
  @Id()
  int id = 0;

  @Unique()
  String code;

  int? status;
  int? rating;
  String? comment;

  PhotoSelectionImageCondition({
    required this.code,
    this.status,
    this.rating,
    this.comment,
  });
}

@Entity()
class PhotoSelection {
  @Id()
  int id = 0;

  @Unique()
  String code;

  String eventCode;
  bool published;
  bool confirmedStatus;
  int lastUpdatedAt;
  int confirmedLastUpdatedAt;

  PhotoSelection({
    this.id = 0,
    required this.code,
    required this.eventCode,
    this.published = false,
    this.confirmedStatus = false,
    required this.lastUpdatedAt,
    this.confirmedLastUpdatedAt = 0,
  });
}

@Entity()
class TransportData {
  @Id()
  int id = 0;

  @Unique()
  String code;

  String? tag;

  int lastUpdatedAt;

  int updateRequired;

  String? data;

  String? role;

  TransportData({
    required this.code,
    this.tag,
    required this.lastUpdatedAt,
    this.updateRequired = 0,
    this.data,
    this.role,
  });
}

@Entity()
class UploadState {
  @Id()
  int id = 0;

  String? eventName;

  String albumName;

  String? uploadingImageName;

  int? totalFilesCount;

  int? remainingFilesCount;

  bool? uploadComplete;

  UploadState({
    this.id = 0,
    this.eventName,
    required this.albumName,
    this.uploadingImageName,
    this.totalFilesCount,
    this.remainingFilesCount,
    this.uploadComplete = false,
  });
}
