import 'package:photomall_studio_manager/api/apiResponseModels/album_index_response.dart';
import 'package:photomall_studio_manager/database/dao/album_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../database/object_box_model/object_box_models.dart';
import '../main.dart';

class AlbumController {
  upsertAlbum({
    required String eventCode,
    required AlbumIndexResponse albums,
  }) async {
    final albumModelDao = objectBox.albumModelDao;
    List<String> apialbums = [];
    for (Media media in albums.medias!) {
      apialbums.add(media.mediable!.code!);
    }
    List<String> existingEvents = [];
    if (apialbums.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local
      List<Album>? albumAtDB =
          await albumModelDao.getAlbumWhereEventCode(eventCode);
      if (albumAtDB != null && albumAtDB.isNotEmpty) {
        for (var _event in albumAtDB) {
          existingEvents.add(_event.code);
        }
      }
      for (int i = 0; i < apialbums.length; i++) {
        if (existingEvents.contains(apialbums[i])) {
          update.add(apialbums[i]);
        }
        if (!existingEvents.contains(apialbums[i])) {
          create.add(apialbums[i]);
        }
      }
      for (int i = 0; i < existingEvents.length; i++) {
        if (!apialbums.contains(existingEvents[i])) {
          delete.add(existingEvents[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        showLog('INSERT New$create');
        List<Album> newAlbumsEntity = [];
        for (int i = 0; i < create.length; i++) {
          Media? newMedia = albums.medias!
              .where((obj) => obj.mediable!.code == create[i])
              .toList()
              .first;
          newAlbumsEntity.add(Album(
              deviceId: newMedia.mediable?.albumPath?.path,
              code: newMedia.mediable!.code!,
              name: newMedia.mediable!.name!,
              path: newMedia.mediable!.albumPath?.path,
              eventCode: eventCode,
              type: newMedia.mediable!.albumType ?? 0,
              size: newMedia.mediable!.albumSize?.size,
              orderLastUpdatedAt: 0,
              lastUpdatedAt: newMedia.lastUpdatedAt!));

          showLog('INSERT}$newAlbumsEntity');

          if (newAlbumsEntity.isNotEmpty) {
            await albumModelDao.insertAllAlbum(newAlbumsEntity);
            showLog('newAlbumsEntity1');
          }
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        List<Album> updateAlbumEntity = [];
        for (int i = 0; i < update.length; i++) {
          Media? updateMedia = albums.medias!
              .where((obj) => obj.mediable!.code == update[i])
              .toList()
              .first;
          Album? updateAlbum = albumAtDB!
              .where((element) => element.code == updateMedia.mediable!.code)
              .toList()
              .first;
          updateAlbumEntity.add(Album(
              deviceId: updateAlbum.deviceId,
              code: updateMedia.mediable!.code!,
              name: updateMedia.mediable!.name!,
              path: updateMedia.mediable!.albumPath?.path,
              eventCode: eventCode,
              type: updateMedia.mediable!.albumType ?? 0,
              size: updateMedia.mediable!.albumSize?.size,
              lastUpdatedAt: updateMedia.lastUpdatedAt!,
              orderLastUpdatedAt: updateAlbum.lastUpdatedAt));
        }
        showLog('INSERT}$updateAlbumEntity');
        if (updateAlbumEntity.isNotEmpty) {
          await albumModelDao.insertAllAlbum(updateAlbumEntity);
        }
      }

      /// DELETE
      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await albumModelDao.deleteAlbumWhereCode(delete[i]);
        }
      }
    } else {
      showLog("media is empty in api so delete");
      await albumModelDao.deleteAlbum(eventCode);
    }
  }
}
