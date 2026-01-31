import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../main.dart';
import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class PhotoSelectionImageStatusDao {
//   AppDb database = AppDb();
//
//   Future<void> insertAllImages(
//       List<PhotoSelectionImageConditionCompanion> entity) async {
//     if (entity.isNotEmpty) {
//       showLog('insertAllImages entity ${entity.length}');
//       await database.batch((batch) {
//         return batch.insertAllOnConflictUpdate(
//             database.photoSelectionImageCondition, entity);
//       });
//     }
//   }
//
//   Future<List<PhotoSelectionImageConditionData?>> getImageStatusWhereEventCode(
//       String eventCode) async {
//     var query = await (database.select(database.folders)
//           ..where((tbl) => tbl.eventCode.equals(eventCode)))
//         .join([
//       drift.innerJoin(
//           database.photoSelectionImages,
//           ((database.photoSelectionImages.folderCode
//               .equalsExp(database.folders.code)))),
//       drift.innerJoin(
//           database.photoSelectionImageCondition,
//           ((database.photoSelectionImageCondition.code
//               .equalsExp(database.photoSelectionImages.code)))),
//     ]).get();
//     return query.map((rows) {
//       return rows.readTableOrNull(database.photoSelectionImageCondition);
//     }).toList();
//   }
//
//   Future<void> deleteImagesStatus(String code) async {
//     await (database.delete(database.photoSelectionImageCondition)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
// }
class PhotoSelectionImageStatusDao {
  final Box<PhotoSelectionImageCondition>box;
  PhotoSelectionImageStatusDao(Store store):box =store.box<PhotoSelectionImageCondition>();

  Future<void> insertAllImages(List<PhotoSelectionImageCondition> entities) async {
    if (entities.isEmpty) return;

    showLog('insertAllImages entity ${entities.length}');

    // 1. Get existing objects for the given codes
    final codes = entities.map((e) => e.code).toList();
    final existingObjects = box.query(PhotoSelectionImageCondition_.code.oneOf(codes)).build().find();

    // 2. Create a map of code -> existing object ID
    final Map<String, int> existingCodeToId = {
      for (var obj in existingObjects) obj.code : obj.id
    };

    // 3. Assign IDs to entities to update instead of insert if exists
    for (var entity in entities) {
      if (existingCodeToId.containsKey(entity.code)) {
        entity.id = existingCodeToId[entity.code]!;
      }
    }

    // 4. Insert or update all
    box.putMany(entities);
  }

  Future<List<PhotoSelectionImageCondition>> getImageStatusWhereEventCode(String eventCode) async {
    final folderModelDao = objectBox.folderModelDao;

    final folders = await folderModelDao.getFolderWhereEventCode(eventCode);
    final List<PhotoSelectionImageCondition> result = [];
    final imageModelDao = objectBox.imageModelDao;

    for (final folder in folders) {
      final images = imageModelDao.box
          .query(PhotoSelectionImage_.folderCode.equals(folder.code))
          .build()
          .find();


      for (final image in images) {
        final condition = box
            .query(PhotoSelectionImageCondition_.code.equals(image.code!))
            .build()
            .findFirst();

        if (condition != null) {
          result.add(condition);
        }
      }
    }

    return result;
  }


  Future<void> deleteImagesStatus(String code) async {
    final condition = box
        .query(PhotoSelectionImageCondition_.code.equals(code))
        .build()
        .findFirst();

    if (condition != null) {
      box.remove(condition.id); // ObjectBox deletes by ID
    }
  }
}
