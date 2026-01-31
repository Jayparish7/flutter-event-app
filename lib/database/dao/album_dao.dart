import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/database/dao/order_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as app_db;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import '../../main.dart';
import '../../objectbox.g.dart';
import '../object_box_model/object_box_models.dart';

/*class AlbumModelDao {
  AppDb database = AppDb();

  Future<void> insertAllAlbum(List<AlbumsCompanion> entity) async {
    await database.batch((batch) {
      return batch.insertAllOnConflictUpdate(database.albums, entity);
    });
  }

  Future<int> updateModifiedTimeWhereAlbumCode(
      {required String albumCode, required String modifiedTime}) async {
    return await (database.update(database.albums)
          ..where((tbl) => tbl.code.equals(albumCode)))
        .write(
            AlbumsCompanion(directoryModifiedTime: drift.Value(modifiedTime)));
  }

  Future<List<Album>?> getAlbumWhereEventCode(String eventCode) async {
    return await (database.select(database.albums)
          ..where((tbl) {
            return tbl.eventCode.equals(eventCode);
          }))
        .get();
  }

  Future<Album?> getAlbumWhereCode(String code) async {
    return await (database.select(database.albums)
          ..where((tbl) {
            return tbl.code.equals(code);
          })
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<UploadModel>?> getEventImagesForUpload(String eventCode) async {
    var query = await (database.select(database.albums)
          ..where((tbl) => tbl.eventCode.equals(eventCode)))
        .join([
      drift.innerJoin(
          database.orders,
          ((database.orders.albumCode.equalsExp(database.albums.code)) &
              (database.orders.uploaded.equals(false)))),
    ]).get();
    return query.map((rows) {
      return UploadModel(
        order: rows.readTableOrNull(database.orders),
        album: rows.readTableOrNull(database.albums),
      );
    }).toList();
  }

  Future<void> deleteAlbum(String eventCode) async {
    List<Album>? albums = await getAlbumWhereEventCode(eventCode);
    if (albums != null) {
      OrderModelDao orderModelDao = OrderModelDao();
      for (Album album in albums) {
        await orderModelDao.deleteOrdersWhereAlbumCode(album.code);
      }
    }
    await (database.delete(database.albums)
          ..where((tbl) => tbl.eventCode.equals(eventCode)))
        .go();
  }

  Future<void> deleteAlbumWhereCode(String code) async {
    Album? album = await getAlbumWhereCode(code);
    if (album != null) {
      OrderModelDao orderModelDao = OrderModelDao();

      await orderModelDao.deleteOrdersWhereAlbumCode(album.code);
    }
    await (database.delete(database.albums)
          ..where((tbl) => tbl.code.equals(code)))
        .go();
  }

  Future<int> updateFilesCountWhereAlbumCode(
      {required String code, required int filesCount}) async {
    return await (database.update(database.albums)
          ..where((tbl) => tbl.code.equals(code)))
        .write(AlbumsCompanion(filesCount: drift.Value(filesCount)));
  }

  Future<int> updateUploadStatusWhereAlbumCode(
      int status, String albumCode) async {
    return await (database.update(database.albums)
          ..where((tbl) => tbl.code.equals(albumCode)))
        .write(AlbumsCompanion(uploadStatus: drift.Value(status)));
  }
}*/
class AlbumModelDao {
  final Box<Album> box;

  AlbumModelDao(Store store) : box = store.box<Album>();
  Future<void> upsertAllAlbums(List<Album> entity,
      {PutMode mode = PutMode.put}) async {
    box.putMany(entity, mode: mode);
  }

  Future<void> insertAllAlbum(List<Album> newAlbums) async {
    final codes = newAlbums.map((e) => e.code).toList();

    // Fetch all existing albums at once
    final existingAlbums = box.query(Album_.code.oneOf(codes)).build().find();

    // Create a map of code -> album
    final existingMap = {
      for (final album in existingAlbums) album.code: album.id,
    };

    // Assign IDs to albums that already exist (for update)
    for (final album in newAlbums) {
      if (existingMap.containsKey(album.code)) {
        album.id = existingMap[album.code]!;
      }
    }

    // Batch insert/update
    box.putMany(newAlbums);
  }

  Future<void> updateModifiedTimeWhereAlbumCode(
      {required String albumCode, required String modifiedTime}) async {
    final album = box.query(Album_.code.equals(albumCode)).build().findFirst();
    if (album != null) {
      album.directoryModifiedTime = modifiedTime;
      box.put(album);
    }
  }

  /// Get albums by event code
  Future<List<Album>> getAlbumWhereEventCode(String eventCode) async {
    return box.query(Album_.eventCode.equals(eventCode)).build().find();
  }

  /// Get album by code
  Future<Album?> getAlbumWhereCode(String code) async {
    return box.query(Album_.code.equals(code)).build().findFirst();
  }

  Future<void> deleteAlbum(String eventCode) async {
    showLog("deleteAlbum objectBox");
    final orderModelDao = objectBox.orderModelDao;

    List<Album>? albums = await getAlbumWhereEventCode(eventCode);
    if (albums != null) {

      for (Album album in albums) {
        await orderModelDao.deleteOrdersWhereAlbumCode(album.code);
      }
      box.removeMany(albums.map((e) => e.id).toList());
    }
  }

  Future<void> deleteAlbumWhereCode(String code) async {
    showLog("deleteAlbumWhereCode objectBox");
    final orderModelDao = objectBox.orderModelDao;

    Album? album = await getAlbumWhereCode(code);
    if (album != null) {


      await orderModelDao.deleteOrdersWhereAlbumCode(album.code);
      box.remove(album.id);
    }
  }

  /// Update files count
  Future<void> updateFilesCountWhereAlbumCode({
    required String code,
    required int filesCount,
  }) async {
    final album = box.query(Album_.code.equals(code)).build().findFirst();
    if (album != null) {
      album.filesCount = filesCount;
      box.put(album);
    }
  }

  /// Update upload status
  Future<void> updateUploadStatusWhereAlbumCode(
      int status, String albumCode) async {
    final album = box.query(Album_.code.equals(albumCode)).build().findFirst();
    if (album != null) {
      album.uploadStatus = status;
      box.put(album);
    }
  }
}

class UploadModel {
  final Album? album;
  final Order? order;

  UploadModel({this.album, this.order});
}
