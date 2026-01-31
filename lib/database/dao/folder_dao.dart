import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as app_db;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../main.dart';
import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

// class FolderModelDao {
//   AppDb database = AppDb();
//
//   Future<List<Folder>?> getFolderWhereEventCode(String eventCode) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return (tbl.eventCode.equals(eventCode));
//             }))
//           .get();
//     } catch (e) {
//       showLog("problem in folder dao getFolderWhereCode $e");
//       return null;
//     }
//   }
//
//   Future<List<Folder>?> getFolderWhereFolderCode(String folderCode) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return (tbl.code.equals(folderCode));
//             }))
//           .get();
//     } catch (e) {
//       showLog("problem in folder dao getFolderWhereCode $e");
//       return null;
//     }
//   }
//
//   Future<Folder?> getFolderWhereode(String code) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return (tbl.code.equals(code));
//             })
//             ..limit(1))
//           .getSingleOrNull();
//     } catch (e) {
//       showLog("problem in folder dao getFolderWhereCode $e");
//       return null;
//     }
//   }
//
//   insertFolder(FoldersCompanion folder) async {
//     showLog('the folder inserting function called');
//     return await database.into(database.folders).insert(folder);
//   }
//
//   updateSegricationFormate(String folderCode, String formate) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.code.equals(folderCode)))
//         .write(FoldersCompanion(segregationFormat: drift.Value(formate)));
//   }
//
//   updateSegricationPath(String folderCode, String path) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.code.equals(folderCode)))
//         .write(FoldersCompanion(segregationPath: drift.Value(path)));
//   }
//
//   updateCustomSegregationPath(String folderCode, String path) async {
//     showLog(
//         'updateCustomSegregationPath == >the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.code.equals(folderCode)))
//         .write(FoldersCompanion(customSegregationPath: drift.Value(path)));
//   }
//
//   updateSegregationPathByFolderName(
//       {required String folderName, required String path}) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.name.equals(folderName)))
//         .write(FoldersCompanion(segregationPath: drift.Value(path)));
//   }
//
//   updateCustomSegregationPathByFolderName(
//       {required String folderName, required String path}) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.name.equals(folderName)))
//         .write(FoldersCompanion(customSegregationPath: drift.Value(path)));
//   }
//
//   updateSegregationFormatByFolderName(
//       {required String folderName, required String format}) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.name.equals(folderName)))
//         .write(FoldersCompanion(segregationFormat: drift.Value(format)));
//   }
//
//   updateFilesCount(
//       {required String folderCode, required int filesCount}) async {
//     showLog('the folder inserting function called');
//     return await (database.update(database.folders)
//           ..where((tbl) => tbl.code.equals(folderCode)))
//         .write(FoldersCompanion(filesCount: drift.Value(filesCount)));
//   }
//
//   getFolderFilesCount({required String folderCode}) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return ((tbl.code.equals(folderCode)));
//             }))
//           .getSingle();
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<Folder?> getFolderWhereCode(String code) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return (tbl.code.equals(code));
//             })
//             ..limit(1))
//           .getSingleOrNull();
//     } catch (e) {
//       showLog("problem in folder dao getFolderWhereCode $e");
//       return null;
//     }
//   }
//
//   Future<int> updateUploadStatus(int status, String folderCode) async {
//     return await (database.update(database.folders)
//           ..where((tbl) {
//             return tbl.code.equals(folderCode);
//           }))
//         .write(FoldersCompanion(uploadStatus: drift.Value(status)));
//   }
//
//   Stream<List<Folder>> getSubFolderWhereParentCode(String code) {
//     return (database.select(database.folders)
//           ..where((tbl) {
//             return (tbl.parentCode.equals(code));
//           }))
//         .watch();
//   }
//
//   Future<List<Folder>> getSubFolderWhereParent(String code) {
//     return (database.select(database.folders)
//           ..where((tbl) {
//             return (tbl.parentCode.equals(code));
//           }))
//         .get();
//   }
//
//   Future<Folder?> getFoldersByEventAndParentNull(
//     String eventCode,
//   ) async {
//     try {
//       return await (database.select(database.folders)
//             ..where((tbl) {
//               return ((tbl.eventCode.equals(eventCode)) &
//                   (tbl.parentCode.isNull()));
//             })
//             ..limit(1))
//           .getSingleOrNull();
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<void> deleteFolders() async {
//     await (database.delete(database.folders)).go();
//   }
//
//   Future<void> deleteFoldersWhereCode(String code) async {
//     await (database.delete(database.folders)
//           ..where((tbl) => tbl.code.equals(code)))
//         .go();
//   }
//
//   Future<void> deleteFoldersWhereEventCode(String eventCode) async {
//     ImageModelDao imageModelDao = ImageModelDao();
//     List<Folder>? folders = await getFolderWhereEventCode(eventCode);
//     if (folders != null && folders.isNotEmpty) {
//       for (Folder folder in folders) {
//         await imageModelDao.deleteImagesWhereCode(folder.code);
//       }
//     }
//     await (database.delete(database.folders)
//           ..where((tbl) => tbl.eventCode.equals(eventCode)))
//         .go();
//   }
//
//   Future<void> insertAllFolderss(List<FoldersCompanion> entity) async {
//     await database.batch((batch) {
//       return batch.insertAllOnConflictUpdate(database.folders, entity);
//     });
//   }
// }
class FolderModelDao {
  final Box<Folder> box;

  FolderModelDao(Store store) : box = store.box<Folder>();

  Future<List<Folder>> getFolderWhereEventCode(String eventCode) async {
    final query = box.query(Folder_.eventCode.equals(eventCode)).build();
    final result = query.find();
    query.close();
    return result;
  }

  Future<List<Folder>> getFolderWhereFolderCode(String folderCode) async {
    final query = box.query(Folder_.code.equals(folderCode)).build();
    final result = query.find();
    query.close();
    return result;
  }

  Future<Folder?> getFolderWhereCode(String code) async {
    final query = box.query(Folder_.code.equals(code)).build();
    final folder = query.findFirst();
    query.close();
    return folder;
  }

 Future<int> insertFolder(Folder folder) async {
    // Check if a folder with the same 'code' exists
    final query = box.query(Folder_.code.equals(folder.code)).build();
    final existingFolder = query.findFirst();
    query.close();

    if (existingFolder != null) {
      folder.id = existingFolder.id; // Assign existing ID to update instead of insert
    }

    // put() will insert or update based on the presence of folder.id
    return box.put(folder);
  }

  Future<void> insertAllFolders(List<Folder> folders) async {
    box.putMany(folders);
  }

  Future<void> updateSegregationFormat(String folderCode, String format) async {
    final folder = await getFolderWhereCode(folderCode);
    if (folder != null) {
      folder.segregationFormat = format;
      box.put(folder);
    }
  }

  Future<void> updateSegregationPath(String folderCode, String path) async {
    final folder = await getFolderWhereCode(folderCode);
    if (folder != null) {
      folder.segregationPath = path;
      box.put(folder);
    }
  }

  Future<void> updateCustomSegregationPath(
      String folderCode, String path) async {
    final folder = await getFolderWhereCode(folderCode);
    if (folder != null) {
      folder.customSegregationPath = path;
      box.put(folder);
    }
  }

  Future<void> updateFilesCount({required String folderCode, required int count}) async {
    final folder = await getFolderWhereCode(folderCode);
    if (folder != null) {
      folder.filesCount = count;
      box.put(folder);
    }
  }

  Future<void> updateSegregationPathByFolderName({
    required String folderName,
    required String path,
  }) async {
    final query = box.query(Folder_.name.equals(folderName)).build();
    final folders = query.find();
    query.close();
    for (var folder in folders) {
      folder.segregationPath = path;
    }
    box.putMany(folders);
  }

  Future<void> updateCustomSegregationPathByFolderName({
    required String folderName,
    required String path,
  }) async {
    final query = box.query(Folder_.name.equals(folderName)).build();
    final folders = query.find();
    query.close();
    for (var folder in folders) {
      folder.customSegregationPath = path;
    }
    box.putMany(folders);
  }

  Future<void> updateSegregationFormatByFolderName({
    required String folderName,
    required String format,
  }) async {
    final query = box.query(Folder_.name.equals(folderName)).build();
    final folders = query.find();
    query.close();
    for (var folder in folders) {
      folder.segregationFormat = format;
    }
    box.putMany(folders);
  }

  // Update uploadStatus by folderCode
  Future<void> updateUploadStatus(int status, String folderCode) async {
    final query = box.query(Folder_.code.equals(folderCode)).build();
    final folders = query.find();
    query.close();
    for (var folder in folders) {
      folder.uploadStatus = status;
    }
    box.putMany(folders);
  }

// Stream of subfolders where parentCode == code
  Stream<List<Folder>> getSubFolderWhereParentCode(String code) {
    final query = box
        .query(Folder_.parentCode.equals(code))
        .watch(triggerImmediately: true);
    return query.map((query) => query.find());
  }

// Get list of subfolders where parentCode == code (single future)
  Future<List<Folder>> getSubFolderWhereParent(String code) async {
    final query = box.query(Folder_.parentCode.equals(code)).build();
    final result = query.find();
    query.close();
    return result;
  }

// Get a folder where eventCode == eventCode and parentCode is null
  Future<Folder?> getFoldersByEventAndParentNull(String eventCode) async {
    final query = box
        .query(
          Folder_.eventCode.equals(eventCode) & Folder_.parentCode.isNull(),
        )
        .build();
    final folder = query.findFirst();
    query.close();
    return folder;
  }

// Delete all folders
  Future<void> deleteFolders() async {
    box.removeAll();
  }

// Delete folders by code
  Future<void> deleteFoldersWhereCode(String code) async {
    final query = box.query(Folder_.code.equals(code)).build();
    final foldersToDelete = query.find();
    query.close();
    for (var folder in foldersToDelete) {
      box.remove(folder.id);
    }
  }

  Future<void> deleteFoldersWhereEventCode(String eventCode) async {

    List<Folder>? folders = await getFolderWhereEventCode(eventCode);
    final imageModelDao = objectBox.imageModelDao;

    if (folders != null && folders.isNotEmpty) {
      for (Folder folder in folders) {
        await imageModelDao.deleteImagesWhereCode(folder.code);
      }
    }

    for (final folder in folders) {
      box.remove(folder.id);
    }
  }

  Future<void> insertAllFolder(List<Folder> folders) async {
    for (final folder in folders) {
      final existing =
          box.query(Folder_.code.equals(folder.code)).build().findFirst();
      if (existing != null) {
        folder.id = existing.id; // treat as update
      }
    }
    box.putMany(folders);
  }
}
