import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

//
// class UploadStatusDao {
//   AppDb database = AppDb();
//
//   Future<void> insertUploadStatus(List<UploadStateCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.uploadState, entity);
//     });
//   }
//   Future<List<UploadStateData>?> getUploadData(
//       ) async {
//     return await (database.select(database.uploadState)
//       )
//         .get();
//   }
//   Future<List<UploadStateData>?> getUploadStateWhereEventCode(
//       String eventCode) async {
//     return await (database.select(database.uploadState)
//           ..where((tbl) {
//             return tbl.eventName.equals(eventCode);
//           }))
//         .get();
//   }
//
//   Future<UploadStateData?> getUploadStateWhereAlbumName(
//       {required String albumName}) async {
//     return await (database.select(database.uploadState)
//           ..where((tbl) {
//             return tbl.albumName.equals(albumName);
//           })
//           ..limit(1))
//         .getSingleOrNull();
//   }
//
//   Stream<List<UploadStateData>> streamUploadState() {
//     return database.select(database.uploadState).watch();
//   }
//
//   Future<int> updateUploadStateWhereAlbumName(
//       {required String albumName,
//       required String uploadingName,
//       required int remainingFileCount}) async {
//     showLog("updateUploadStateWhereAlbumName database $remainingFileCount $albumName");
//     return await (database.update(database.uploadState)
//           ..where((tbl) => tbl.albumName.equals(albumName)))
//         .write(UploadStateCompanion(
//             uploadingImageName: drift.Value(uploadingName),
//             remainingFilesCount: drift.Value(remainingFileCount)));
//   }
//
//   Future<int> updateUploadStateWhenCompleted(
//       {required String albumName,
//       required String uploadingName,
//       required int remainingFileCount}) async {
//     return await (database.update(database.uploadState)
//           ..where((tbl) => tbl.albumName.equals(albumName)))
//         .write(UploadStateCompanion(
//             uploadingImageName: drift.Value(uploadingName),
//             remainingFilesCount: drift.Value(remainingFileCount)));
//   }
//   Future<void> deleteUploadStatus() async {
//     await (database.delete(database.uploadState)).go();
//   }Future<void> deleteUploadStatusById(int id) async {
//     await (database.delete(database.uploadState)..where((tbl)=>tbl.id.equals(id))).go();
//   }
// }
class UploadStatusDao {
  final Box<UploadState> box;

  UploadStatusDao(Store store) : box = store.box<UploadState>();

  Future<void> insertUploadStatus(List<UploadState> entities) async {
    showLog("insertUploadStatus objectBox: $entities");
    // ObjectBox putMany does upsert automatically
    for (var entity in entities) {
      final existing = box.query(UploadState_.albumName.equals(entity.albumName)).build().findFirst();
      if (existing != null) {
        entity.id = existing.id; // set existing ID for update
      }
    }
    box.putMany(entities);
  }

  List<UploadState> getUploadData() {
    return box.getAll();
  }

  List<UploadState> getUploadStateWhereEventName(String eventName) {
    final query = box.query(UploadState_.eventName.equals(eventName)).build();
    final result = query.find();
    query.close();
    return result;
  }

  UploadState? getUploadStateWhereAlbumName(String albumName) {
    final query = box.query(UploadState_.albumName.equals(albumName)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Stream<List<UploadState>> streamUploadState() {
    return box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  void updateUploadStateWhereAlbumName({
    required String albumName,
    required String uploadingName,
    required int remainingFileCount,
  }) {
    showLog("updateUploadStateWhereAlbumName $uploadingName");
    final uploadState = getUploadStateWhereAlbumName(albumName);
    if (uploadState != null) {
      uploadState.uploadingImageName = uploadingName;
      uploadState.remainingFilesCount = remainingFileCount;
      box.put(uploadState);
    }
  }

  void updateUploadStateWhenCompleted({
    required String albumName,
    required String uploadingName,
    required int remainingFileCount,
  }) {
    final uploadState = getUploadStateWhereAlbumName(albumName);
    if (uploadState != null) {
      uploadState.uploadingImageName = uploadingName;
      uploadState.remainingFilesCount = remainingFileCount;
      uploadState.uploadComplete = true;
      box.put(uploadState);
    }
  }

  void deleteUploadStatus() {
    showLog("deleteUploadStatus");
    box.removeAll();
  }

  void deleteUploadStatusById(int id) {
      box.remove(id);
  }
}
