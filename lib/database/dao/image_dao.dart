import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:photomall_studio_manager/database/dao/ps_image_status.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;

import '../../main.dart';
import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class ImageModelDao {
//   AppDb database = AppDb();
//
//   Future<void> insertAllImages(
//       {required List<PhotoSelectionImagesCompanion> imagesCompanion}) async {
//     if (imagesCompanion.isNotEmpty) {
//       await database.batch((batch) {
//         return batch.insertAllOnConflictUpdate(
//             database.photoSelectionImages, imagesCompanion);
//       });
//     }
//   }
//
//   Future<void> insertImages(
//       {required PhotoSelectionImagesCompanion imagesCompanion}) async {
//     await (database.into(database.photoSelectionImages))
//         .insert(imagesCompanion);
//   }
//
//   Stream<List<PhotoSelectionImage>> streamImagesWhereFolderCode(
//       String folderCode) {
//     return (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode));
//           }))
//         .watch();
//   }
//
//   Stream<List<PhotoSelectionImage>> streamImageNamesWhereUploadedAndFolderCode(
//       String folderCode) {
//     return (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return tbl.folderCode.equals(folderCode) &
//                 tbl.uploaded.equals(true);
//           }))
//         .watch();
//   }
//
//   Future<List<PhotoSelectionImage>> getImagesWhereFolderCode(
//       String folderCode) async {
//     return await (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode));
//           }))
//         .get();
//   }
//
//   Future<void> updateImageUploadedStatusTrue(
//     int id,
//     String code,
//     String path,
//   ) async {
//     await (database.update(database.photoSelectionImages)
//           ..where((tbl) => tbl.id.equals(id)))
//         .write(PhotoSelectionImagesCompanion(
//       uploaded: const drift.Value(true),
//       code: drift.Value(code),
//       path: drift.Value(path),
//     ));
//   }
//
//   Future<void> updateImage(String id) async {
//     await (database.update(database.folders)
//           ..where((tbl) => tbl.code.equals(id)))
//         .write(const FoldersCompanion(path: drift.Value(null)));
//   }
//
//   Future<void> updateImageMd5Hash(
//       {required String md5Hash,
//       required String sha256,
//       required String presignedUrlCode}) async {
//     await (database.update(database.photoSelectionImages)
//           ..where((tbl) => tbl.sha256.equals(sha256)))
//         .write(PhotoSelectionImagesCompanion(
//       md5hash: drift.Value(md5Hash),
//       preSignedURlCode: drift.Value(presignedUrlCode),
//     ));
//   }
//
//   Future<PhotoSelectionImage?> getImageWhereSha256(String sha256) async {
//     return await (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.sha256.equals(sha256));
//           }))
//         .getSingleOrNull();
//   }
//
//   Future<List<PhotoSelectionImage>?> getImagesNotUploadedInOrder(
//       String folderCode) async {
//     return await (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode) &
//                 tbl.uploaded.equals(false));
//           })
//           ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
//         .get();
//   }
//
//   Future<List<PhotoSelectionImage>?> getImagesNotuploaded(
//       String folderCode) async {
//     return await (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode) &
//                 tbl.uploaded.equals(false));
//           })
//           ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
//         .get();
//   }
//
//   Future<List<PhotoSelectionImage>?> getImagesNotUploadedLimit(
//       String folderCode) async {
//     return await (database.select(database.photoSelectionImages)
//           ..limit(10)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode) &
//                 tbl.uploaded.equals(false));
//           }))
//         .get();
//   }
//
//   Future<List<PhotoSelectionImage>?> getUploadedImages(
//       String folderCode) async {
//     return await (database.select(database.photoSelectionImages)
//           ..where((tbl) {
//             return (tbl.folderCode.equals(folderCode) &
//                 tbl.uploaded.equals(true));
//           }))
//         .get();
//   }
//
//   Future<List<String?>> getSha256ForImages(String folderCode) async {
//     final query = database.select(database.photoSelectionImages)
//       ..addColumns([database.photoSelectionImages.sha256])
//       ..where((tbl) {
//         return (tbl.folderCode.equals(folderCode));
//       });
//
//     final result = await query.get();
//     return result.map((image) => image.sha256).toList();
//   }
//
//   Future<void> deleteImages() async {
//     await (database.delete(database.photoSelectionImages)).go();
//   }
//
//   Future<void> deleteImagesWhereCode(String code) async {
//     PhotoSelectionImageStatusDao photoSelectionImageDao =
//         PhotoSelectionImageStatusDao();
//     await photoSelectionImageDao.deleteImagesStatus(code);
//     await (database.delete(database.photoSelectionImages)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
//
//   Future<void> deleteImagesWhereId(String id) async {
//     PhotoSelectionImageStatusDao photoSelectionImageDao =
//         PhotoSelectionImageStatusDao();
//     await photoSelectionImageDao.deleteImagesStatus(id);
//     await (database.delete(database.photoSelectionImages)
//           ..where((tbl) => tbl.code.equals(id)))
//         .go();
//   }
//
//   Future<void> deleteImagesWhereFolderCode(String folderCode) async {
//     await (database.delete(database.photoSelectionImages)
//           ..where((tbl) => tbl.folderCode.equals(folderCode)))
//         .go();
//   }
//
//   Future<List<SelectedImagesGettingModel>?> getSelectedImages(
//       String eventCode) async {
//     var query = await (database.select(database.events)
//           ..where((tbl) => tbl.code.equals(eventCode)))
//         .join([
//       drift.innerJoin(
//           database.photoSelections,
//           ((database.photoSelections.eventCode
//               .equalsExp(database.events.code)))),
//       drift.innerJoin(database.folders,
//           ((database.folders.eventCode.equalsExp(database.events.code)))),
//       drift.innerJoin(
//           database.photoSelectionImages,
//           ((database.photoSelectionImages.folderCode
//               .equalsExp(database.folders.code)))),
//       drift.innerJoin(
//           database.photoSelectionImageCondition,
//           ((database.photoSelectionImageCondition.code
//                   .equalsExp(database.photoSelectionImages.code)) &
//               (database.photoSelectionImageCondition.status.equals(1)))),
//     ]).get();
//     return query.map((rows) {
//       return SelectedImagesGettingModel(
//         folder: rows.readTableOrNull(database.folders),
//         photoSelectionImage:
//             rows.readTableOrNull(database.photoSelectionImages),
//         status: rows.readTableOrNull(database.photoSelectionImageCondition),
//       );
//     }).toList();
//   }
//
//   Future<List<SelectedImagesGettingModel>?> getSelectedImagesForFolder(
//       String eventCode, String folderCode) async {
//     var query = await (database.select(database.events)
//           ..where((tbl) => tbl.code.equals(eventCode)))
//         .join([
//       drift.innerJoin(
//           database.photoSelections,
//           ((database.photoSelections.eventCode
//               .equalsExp(database.events.code)))),
//       drift.innerJoin(
//           database.folders,
//           ((database.folders.eventCode.equalsExp(database.events.code)) &
//               (database.folders.code.equals(folderCode)))),
//       drift.innerJoin(
//           database.photoSelectionImages,
//           ((database.photoSelectionImages.folderCode
//               .equalsExp(database.folders.code)))),
//       drift.innerJoin(
//           database.photoSelectionImageCondition,
//           ((database.photoSelectionImageCondition.code
//                   .equalsExp(database.photoSelectionImages.code)) &
//               (database.photoSelectionImageCondition.status.equals(1)))),
//     ]).get();
//
//     return query.map((rows) {
//       return SelectedImagesGettingModel(
//         folder: rows.readTableOrNull(database.folders),
//         photoSelectionImage:
//             rows.readTableOrNull(database.photoSelectionImages),
//         status: rows.readTableOrNull(database.photoSelectionImageCondition),
//       );
//     }).toList();
//   }
// }
class ImageModelDao {
  final Box<PhotoSelectionImage> box;

  ImageModelDao(Store store) : box = store.box<PhotoSelectionImage>();
  final folderModelDao = objectBox.folderModelDao;
  final eventModelDao = objectBox.eventModelDao;
  final photoSelectionImageStatusDao = objectBox.photoSelectionImageStatusDao;

  Future<void> insertAllImages(List<PhotoSelectionImage> images) async {
    box.putMany(images);
  }

  Future<void> insertImage(PhotoSelectionImage image) async {
    box.put(image);
  }

  Stream<List<PhotoSelectionImage>> streamImagesWhereFolderCode(
      String folderCode) {
    final query = box.query(PhotoSelectionImage_.folderCode.equals(folderCode));
    return query.watch(triggerImmediately: true).map((q) => q.find());
  }

  Stream<List<PhotoSelectionImage>> streamImageNamesWhereUploadedAndFolderCode(
      String folderCode) {
    final query = box.query(PhotoSelectionImage_.folderCode.equals(folderCode) &
        PhotoSelectionImage_.uploaded.equals(true));
    return query.watch(triggerImmediately: true).map((q) => q.find());
  }

  Future<List<PhotoSelectionImage>> getImagesWhereFolderCode(
      String folderCode) async {
    final query =
        box.query(PhotoSelectionImage_.folderCode.equals(folderCode)).build();
    final result = query.find();
    query.close();

    return result;
  }

  Future<void> updateImageUploadedStatusTrue(
      int id, String code, String path) async {
    final image = box.get(id);
    if (image != null) {
      image.uploaded = true;
      image.code = code;
      image.path = path;
      box.put(image);
    }
  }

  Future<void> updateImageMd5Hash({
    required String md5Hash,
    required String sha256,
    required String presignedUrlCode,
  }) async {
    final query = box.query(PhotoSelectionImage_.sha256.equals(sha256)).build();
    final image = query.findFirst();
    if (image != null) {
      image.md5hash = md5Hash;
      image.preSignedURlCode = presignedUrlCode;
      box.put(image);
    }
  }

  Future<PhotoSelectionImage?> getImageWhereSha256(String sha256) async {
    final query = box.query(PhotoSelectionImage_.sha256.equals(sha256)).build();
    final result = query.findFirst();
    query.close();

    return result;
  }

  Future<List<PhotoSelectionImage>> getImagesNotuploaded(
      String folderCode) async {
    return box
        .query(
          PhotoSelectionImage_.folderCode.equals(folderCode) &
              PhotoSelectionImage_.uploaded.equals(false),
        )
        .order(PhotoSelectionImage_.name)
        .build()
        .find();
  }

  Future<List<PhotoSelectionImage>> getUploadedImages(String folderCode) async {
    return box
        .query(
          PhotoSelectionImage_.folderCode.equals(folderCode) &
              PhotoSelectionImage_.uploaded.equals(true),
        )
        .build()
        .find();
  }

  Future<void> deleteImages() async {
    box.removeAll();
  }

  Future<void> deleteImagesWhereCode(String code) async {
    await photoSelectionImageStatusDao.deleteImagesStatus(code);
    final query = box.query(PhotoSelectionImage_.code.equals(code)).build();
    final result = query.find();
    box.removeMany(result.map((e) => e.id).toList());
  }

  Future<void> deleteImagesWhereId(String id) async {
    await photoSelectionImageStatusDao.deleteImagesStatus(id);
    final query = box.query(PhotoSelectionImage_.code.equals(id)).build();
    final results = query.find();

    if (results.isNotEmpty) {
      box.removeMany(results.map((e) => e.id).toList());
    }

    query.close();
  }

  Future<void> deleteImagesWhereFolderCode(String folderCode) async {
    final query =
        box.query(PhotoSelectionImage_.folderCode.equals(folderCode)).build();
    final imagesToDelete = query.find();

    if (imagesToDelete.isNotEmpty) {
      box.removeMany(imagesToDelete.map((e) => e.id).toList());
    }

    query.close();
  }

  // Future<List<SelectedImagesGettingModel>?> getSelectedImages(
  //     String eventCode) async {
  //   var query = await (database.select(database.events)
  //         ..where((tbl) => tbl.code.equals(eventCode)))
  //       .join([
  //     drift.innerJoin(
  //         database.photoSelections,
  //         ((database.photoSelections.eventCode
  //             .equalsExp(database.events.code)))),
  //     drift.innerJoin(database.folders,
  //         ((database.folders.eventCode.equalsExp(database.events.code)))),
  //     drift.innerJoin(
  //         database.photoSelectionImages,
  //         ((database.photoSelectionImages.folderCode
  //             .equalsExp(database.folders.code)))),
  //     drift.innerJoin(
  //         database.photoSelectionImageCondition,
  //         ((database.photoSelectionImageCondition.code
  //                 .equalsExp(database.photoSelectionImages.code)) &
  //             (database.photoSelectionImageCondition.status.equals(1)))),
  //   ]).get();
  //   return query.map((rows) {
  //     return SelectedImagesGettingModel(
  //       folder: rows.readTableOrNull(database.folders),
  //       photoSelectionImage:
  //           rows.readTableOrNull(database.photoSelectionImages),
  //       status: rows.readTableOrNull(database.photoSelectionImageCondition),
  //     );
  //   }).toList();
  // }
  Future<List<SelectedImagesGettingModel>> getSelectedImages(
      String eventCode) async {
    final event = eventModelDao.box
        .query(Events_.code.equals(eventCode))
        .build()
        .findFirst();
    if (event == null) return [];

    final folders = folderModelDao.box
        .query(Folder_.eventCode.equals(eventCode))
        .build()
        .find();

    // Collect all folder codes at once
    final folderCodes = folders.map((f) => f.code).toList();

    // Fetch all images belonging to these folders in one go
    final images = box
        .query(PhotoSelectionImage_.folderCode.oneOf(folderCodes))
        .build()
        .find();

    // Collect all image codes
    final imageCodes = images.map((img) => img.code!).toList();

    // Fetch all conditions with status==1 and code in imageCodes
    final conditions = photoSelectionImageStatusDao.box
        .query(PhotoSelectionImageCondition_.status
            .equals(1)
            .and(PhotoSelectionImageCondition_.code.oneOf(imageCodes)))
        .build()
        .find();

    // Map conditions by code for quick lookup
    final conditionMap = {for (var c in conditions) c.code: c};

    final List<SelectedImagesGettingModel> results = [];

    // Combine all in one loop for performance
    for (final image in images) {
      final condition = conditionMap[image.code];
      if (condition != null) {
        final folder = folders.firstWhere((f) => f.code == image.folderCode);
        results.add(SelectedImagesGettingModel(
          folder: folder,
          photoSelectionImage: image,
          status: condition,
        ));
      }
    }

    return results;
  }

  Future<List<SelectedImagesGettingModel>> getSelectedImagesForFolder(
      String eventCode, String folderCode) async {
    // 1. Verify event exists (optional but safer)
    final event = await eventModelDao.box
        .query(Events_.code.equals(eventCode))
        .build()
        .findFirst();

    if (event == null) return [];

    // 2. Fetch the folder for eventCode + folderCode
    final folder = await folderModelDao.box
        .query(Folder_.code
            .equals(folderCode)
            .and(Folder_.eventCode.equals(eventCode)))
        .build()
        .findFirst();

    if (folder == null) return [];

    // 3. Fetch images for the folder
    final images = box
        .query(PhotoSelectionImage_.folderCode.equals(folder.code))
        .build()
        .find();

    // 4. Extract image codes
    final imageCodes = images.map((img) => img.code!).toList();

    if (imageCodes.isEmpty) return [];

    // 5. Fetch conditions with status == 1 for these image codes
    final conditions = photoSelectionImageStatusDao.box
        .query(PhotoSelectionImageCondition_.status
            .equals(1)
            .and(PhotoSelectionImageCondition_.code.oneOf(imageCodes)))
        .build()
        .find();

    // 6. Map conditions by code for quick lookup
    final conditionMap = {for (var c in conditions) c.code: c};

    // 7. Build final list of SelectedImagesGettingModel
    final List<SelectedImagesGettingModel> results = [];

    for (final image in images) {
      final condition = conditionMap[image.code];
      if (condition != null) {
        results.add(SelectedImagesGettingModel(
          folder: folder,
          photoSelectionImage: image,
          status: condition,
        ));
      }
    }

    return results;
  }
}

class SelectedImagesGettingModel {
  final Folder? folder;
  final PhotoSelectionImage? photoSelectionImage;
  final PhotoSelectionImageCondition? status;

  SelectedImagesGettingModel(
      {this.folder, this.photoSelectionImage, this.status});
}
