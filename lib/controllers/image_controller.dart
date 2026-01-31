import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_response_model.dart' as api;
import 'package:photomall_studio_manager/database/dao/image_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appdb;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import '../../database/object_box_model/object_box_models.dart';

import '../main.dart';

class ImageController {
  final imageModelDao = objectBox.imageModelDao;

  Future<void> upsertImages(List<api.PhotoSelectionImage>? photoSelectionImages,
      String folderCode) async {
    List<String> apiPhotoSelectionImagesCodes = [];
    for (api.PhotoSelectionImage folder in photoSelectionImages!) {
      showLog('duplicates value message ${folder.originalFileName}');
      apiPhotoSelectionImagesCodes.add(folder.originalFileName!);
    }
    List<String> existingEvents = [];
    if (apiPhotoSelectionImagesCodes.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local

      List<PhotoSelectionImage>? imagesAtDB =
          await imageModelDao.getImagesWhereFolderCode(folderCode);
      if (imagesAtDB.isNotEmpty) {
        for (var event in imagesAtDB) {
          existingEvents.add(event.name ?? '');
        }
      }
      for (int i = 0; i < apiPhotoSelectionImagesCodes.length; i++) {
        if (existingEvents.contains(apiPhotoSelectionImagesCodes[i])) {
          update.add(apiPhotoSelectionImagesCodes[i]);
        }
        if (!existingEvents.contains(apiPhotoSelectionImagesCodes[i])) {
          create.add(apiPhotoSelectionImagesCodes[i]);
        }
      }
      for (int i = 0; i < existingEvents.length; i++) {
        if (!apiPhotoSelectionImagesCodes.contains(existingEvents[i])) {
          delete.add(existingEvents[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        List<PhotoSelectionImage> newImageEntity = [];
        for (int i = 0; i < create.length; i++) {
          api.PhotoSelectionImage? newImage = photoSelectionImages
              .where((obj) => obj.originalFileName == create[i])
              .toList()
              .first;

          newImageEntity.add(PhotoSelectionImage(
            code: newImage.code!,
            name: newImage.originalFileName!,
            path: "",
            folderCode: folderCode,
            uploaded: true,
            lastUpdatedAt: 0,
          ));
        }
        if (newImageEntity.isNotEmpty) {
          await imageModelDao.insertAllImages( newImageEntity);
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        List<PhotoSelectionImage > updateImageEntity = [];
        for (int i = 0; i < update.length; i++) {
          PhotoSelectionImage dbImage = imagesAtDB
              .where((element) => element.name == update[i])
              .toList()
              .first;
          api.PhotoSelectionImage? updateEvent = photoSelectionImages
              .where((obj) => obj.originalFileName == update[i])
              .toList()
              .first;

          updateImageEntity.add(PhotoSelectionImage(
            id: dbImage.id,
            code: updateEvent.code!,
            name: updateEvent.originalFileName!,
            path:"",
            folderCode: folderCode,
            uploaded: true,
            lastUpdatedAt: 0,
          ));
          showLog("Photo selection images update :: ");
        }
        if (updateImageEntity.isNotEmpty) {
          await imageModelDao.insertAllImages(
               updateImageEntity);
        }
      }

      /// DELETE
      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await imageModelDao.deleteImagesWhereCode(delete[i]);
        }
      }
    }
  }

  Future<List<SelectedImagesGettingModel>?> getSelectedImages(
      String eventCode) async {

    List<SelectedImagesGettingModel>? selectedImages =
        await imageModelDao.getSelectedImages(
      eventCode,
    );
    return selectedImages;
  }  Future<List<SelectedImagesGettingModel>?> getSelectedImagesForFolder(
      String eventCode,String folderCode) async {
    List<SelectedImagesGettingModel>? selectedImages =
        await imageModelDao.getSelectedImagesForFolder(
      eventCode,folderCode
    );
    return selectedImages;
  }
}
