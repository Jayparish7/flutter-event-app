import 'package:photomall_studio_manager/database/model/app_db.dart';

import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class PhotoMallStudioInfoDao {
//   AppDb database = AppDb();
//
//   Future<void> insertAllStudioInfo(
//       {required List<PhotomallStudioInfoCompanion> infoCompanions}) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(
//           database.photomallStudioInfo, infoCompanions);
//     });
//   }
//
//   Future<List<PhotomallStudioInfoData>?> getAllStudioInfoAvailable() async {
//     return await (database.select(database.photomallStudioInfo)).get();
//   }
//
//   Future<PhotomallStudioInfoData?> getStudioInfoWhereCode(
//       String code) async {
//     return await (database.select(database.photomallStudioInfo)
//           ..where((tbl) => tbl.code.equals(code))..limit(1))
//         .getSingleOrNull();
//   }
//
//   Future<void> deletePhotomallStudioInfoWhereCode(String code) async {
//     await (database.delete(database.photomallStudioInfo)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
//
//   Future<void> deletePhotomallStudioInfo() async {
//     await (database.delete(database.photomallStudioInfo)).go();
//   }
// }
class PhotoMallStudioInfoDao {
  final Box<PhotomallStudioInfo> box;

  PhotoMallStudioInfoDao(Store store)
      : box = store.box<PhotomallStudioInfo>();

  /// Insert or update multiple studio info records
  Future<void> insertAllStudioInfo(List<PhotomallStudioInfo> infos,
      {PutMode mode = PutMode.put}) async {
    box.putMany(infos,mode: mode);
  }

  /// Get all studio info
  Future<List<PhotomallStudioInfo>> getAllStudioInfoAvailable() async {
    return box.getAll();
  }

  /// Get single record where code matches
  Future<PhotomallStudioInfo?> getStudioInfoWhereCode(String code) async {
    final query = box.query(PhotomallStudioInfo_.code.equals(code)).build();
    return query.findFirst();
  }

  /// Delete record where code matches
  Future<void> deletePhotomallStudioInfoWhereCode(String code) async {
    final query = box.query(PhotomallStudioInfo_.code.equals(code)).build();
    final result = query.findFirst();
    if (result != null) {
      box.remove(result.id);
    }
  }

  /// Delete all records
  Future<void> deletePhotomallStudioInfo() async {
    box.removeAll();
  }
}
