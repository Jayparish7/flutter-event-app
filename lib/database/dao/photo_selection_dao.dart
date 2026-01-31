

import '../../main.dart';
import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class PhotoSelectionDao {
//
//   AppDb database = AppDb();
//
//   Future<void> insertAllPhotoSelections(
//       List<PhotoSelectionsCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.photoSelections, entity);
//     });
//   }
//
//   Future<PhotoSelection?> getPhotoSelectionWhereEventCode(
//       String eventCode) async {
//     return await (database.select(database.photoSelections)
//           ..where((tbl) {
//             return tbl.eventCode.equals(eventCode) & tbl.code.isNotValue('');
//           }))
//         .getSingleOrNull();
//   }
//
//   Future<PhotoSelection?> getPhotoSelectionWhereCode(String code) async {
//     return await (database.select(database.photoSelections)
//           ..where((tbl) {
//             return tbl.code.equals(code);
//           }))
//         .getSingleOrNull();
//   }
//
//   Future<void> deletePhotoSelections() async {
//     await (database.delete(database.photoSelections)).go();
//   }
//
//   Future<void> deletePhotoSelectionsWhereCode(String code) async {
//     PhotoSelection? photoSelection = await getPhotoSelectionWhereCode(code);
//     if (photoSelection != null) {
//       await deletePhotoSelectionsWhereEventCode(photoSelection.eventCode);
//     }
//   }
//
//   Future<void> deletePhotoSelectionsWhereEventCode(String eventCode) async {
//     final folderModelDao = objectBox.folderModelDao;
//     await folderModelDao.deleteFoldersWhereEventCode(eventCode);
//     await (database.delete(database.photoSelections)
//           ..where((tbl) => tbl.eventCode.equals(eventCode)))
//         .go();
//   }
// }
class PhotoSelectionDao {
  final Box<PhotoSelection> box;
  PhotoSelectionDao(Store store):box=store.box<PhotoSelection>();

  Future<void> insertAllPhotoSelections(List<PhotoSelection> entities) async {

    final toInsert = <PhotoSelection>[];

    for (final entity in entities) {
      final query = box.query(PhotoSelection_.code.equals(entity.code)).build();
      final existing = query.findFirst();
      query.close();

      if (existing == null) {
        toInsert.add(entity);
      } else {
        // Optionally update fields and put again if needed
        entity.id = existing.id; // required for updating
        toInsert.add(entity);
      }
    }

    box.putMany(toInsert);
  }
  Future<PhotoSelection?> getPhotoSelectionWhereEventCode(String eventCode) async {
    final query = box.query(
      PhotoSelection_.eventCode.equals(eventCode).and(
        PhotoSelection_.code.notEquals(''),
      ),
    ).build();

    final result = query.findFirst();
    query.close();
    return result;
  }
  Future<PhotoSelection?> getPhotoSelectionWhereCode(String code) async {
    final query = box.query(
      PhotoSelection_.code.equals(code),
    ).build();

    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<void> deletePhotoSelections() async {
   box.removeAll();
  }

  Future<void> deletePhotoSelectionsWhereCode(String code) async {
    final photoSelection = box.query(PhotoSelection_.code.equals(code)).build().findFirst();
    if (photoSelection != null) {
      await deletePhotoSelectionsWhereEventCode(photoSelection.eventCode);
    }
  }

  Future<void> deletePhotoSelectionsWhereEventCode(String eventCode) async {
    final folderModelDao = objectBox.folderModelDao;

    // Delete related folders first (cascading logic)
    await folderModelDao.deleteFoldersWhereEventCode(eventCode);

    // Delete photo selections with matching eventCode
    final selections = box
        .query(PhotoSelection_.eventCode.equals(eventCode))
        .build()
        .find();

    if (selections.isNotEmpty) {
      box.removeMany(selections.map((e) => e.id).toList());
    }
  }

}
