import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_response_model.dart'as api_model;
import 'package:photomall_studio_manager/controllers/image_controller.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../database/object_box_model/object_box_models.dart';
import '../main.dart';

class FolderController {
  Future<void> upsertFolders(List<api_model.Folder>? apiFolders, String eventCode,
      {String? deviceID}) async {
    ImageController imageController = ImageController();
    List<String> apiFolderCodes = [];
    for (api_model.Folder folder in apiFolders!) {
      showLog("Api folder ${folder.code!}");
      apiFolderCodes.add(folder.code!);
    }
    List<String> existingFolders = [];
    if (apiFolderCodes.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local
      final folderModelDao = objectBox.folderModelDao;
      List<Folder> foldersAtDB =
          await folderModelDao.getFolderWhereEventCode(eventCode);
      if (foldersAtDB != null && foldersAtDB.isNotEmpty) {
        for (var folder in foldersAtDB) {
          showLog("Db folder ${folder.code}");

          existingFolders.add(folder.code);
        }
      }
      for (int i = 0; i < apiFolderCodes.length; i++) {
        if (existingFolders.contains(apiFolderCodes[i])) {
          showLog("Update >> ${apiFolderCodes[i]}");

          update.add(apiFolderCodes[i]);
        }
        if (!existingFolders.contains(apiFolderCodes[i])) {
          showLog("Create >> ${apiFolderCodes[i]}");

          create.add(apiFolderCodes[i]);
        }
      }
      for (int i = 0; i < existingFolders.length; i++) {
        if (!apiFolderCodes.contains(existingFolders[i])) {
        //  showLog("Delete >> ${apiFolderCodes[i]}");

          delete.add(existingFolders[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        List<Folder> newFolderEntity = [];
        for (int i = 0; i < create.length; i++) {
          api_model.Folder? newEvent =
              apiFolders.where((obj) => obj.code == create[i]).toList().first;
          await imageController.upsertImages(
              newEvent.photoSelectionImages, newEvent.code!);

          newFolderEntity.add(Folder(
            deviceId:  deviceID,
            code: newEvent.code!,
            eventCode:eventCode,
            parentCode: newEvent.parentCode,
            name: newEvent.name!,
            lastUpdatedAt: newEvent.lastUpdatedAt!,
            path: newEvent.folderPath?.path ?? "",

            /// error
            sync: true,
          ));
        }
        if (newFolderEntity.isNotEmpty) {
          await folderModelDao.insertAllFolder(newFolderEntity);
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        List<Folder> updateFolderEntity = [];
        for (int i = 0; i < update.length; i++) {
          api_model.Folder? updateEvent =
              apiFolders.where((obj) => obj.code == update[i]).toList().first;
          Folder? db = foldersAtDB!
              .where((element) => element.code == update[i])
              .toList()
              .first;
          await imageController.upsertImages(
              updateEvent.photoSelectionImages, updateEvent.code!);
          updateFolderEntity.add(Folder(
            deviceId: db.deviceId,
            code: updateEvent.code!,
            eventCode: eventCode,
            parentCode: updateEvent.parentCode,
            name: updateEvent.name!,
            lastUpdatedAt: updateEvent.lastUpdatedAt!,
            path: updateEvent.folderPath?.path ?? "",
            sync: true,
          ));
        }
        if (updateFolderEntity.isNotEmpty) {
          await folderModelDao.insertAllFolder(updateFolderEntity);
        }
      }

      /// DELETE

      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await folderModelDao.deleteFoldersWhereCode(delete[i]);
        }
      }
    }
  }
}
