import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_confirm_index.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../database/object_box_model/object_box_models.dart' as model;
import '../main.dart';

class PSImageStatusController {
  Future<void> upsertPhotoSelectionImageStaus(
      List<PhotoSelectionImage>? photoSelectionImage, String eventCode) async {
    List<String> apiImageStatus = [];
    showLog('upsertPhotoSelectionImageStaus${photoSelectionImage?.length}');

    for (PhotoSelectionImage images in photoSelectionImage!) {
      apiImageStatus.add(images.code!);
    }
    showLog('upsertPhotoSelectionImageStaus');
    List<String> existingImageStatus = [];
    if (apiImageStatus.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local
      final photoSelectionImageStatusDao = objectBox.photoSelectionImageStatusDao;

      List<model.PhotoSelectionImageCondition?>? imagesAtDB =
          await photoSelectionImageStatusDao
              .getImageStatusWhereEventCode(eventCode);
      showLog('upsertPhotoSelectionImageStaus at db ${imagesAtDB.length}');

      if (imagesAtDB != null && imagesAtDB.isNotEmpty) {
        for (var status in imagesAtDB) {
          if (status != null) {
            existingImageStatus.add(status.code);
          }
        }
      }
      for (int i = 0; i < apiImageStatus.length; i++) {
        if (existingImageStatus.contains(apiImageStatus[i])) {
          update.add(apiImageStatus[i]);
        }
        if (!existingImageStatus.contains(apiImageStatus[i])) {
          create.add(apiImageStatus[i]);
        }
      }
      for (int i = 0; i < existingImageStatus.length; i++) {
        if (!apiImageStatus.contains(existingImageStatus[i])) {
          delete.add(existingImageStatus[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        showLog('upsertPhotoSelectionImageStaus create');

        List<model.PhotoSelectionImageCondition> newImageStatusEntity =
            [];
        for (int i = 0; i < create.length; i++) {
          PhotoSelectionImage? newOrder = photoSelectionImage
              .where((obj) => obj.code == create[i])
              .toList()
              .first;

          newImageStatusEntity.add(model.PhotoSelectionImageCondition(
            code:  newOrder.code!,
            rating: newOrder.rating,
            status: newOrder.status,
            comment:newOrder.comment,
          ));
        }
        if (newImageStatusEntity.isNotEmpty) {
          showLog('newImageStatusEntity --- 12332 ${newImageStatusEntity.length}');
          await photoSelectionImageStatusDao
              .insertAllImages(newImageStatusEntity);
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        showLog('upsertPhotoSelectionImageStaus update');

        List< model.PhotoSelectionImageCondition>
            updateImageStatusEntity = [];
        for (int i = 0; i < update.length; i++) {
          PhotoSelectionImage? updateOrder = photoSelectionImage
              .where((obj) => obj.code == update[i])
              .toList()
              .first;
          updateImageStatusEntity
              .add(model.PhotoSelectionImageCondition(
            code: updateOrder.code!,
            rating: updateOrder.rating,
            status: updateOrder.status,
            comment: updateOrder.comment,
          ));
          showLog("Photo selection images update :: ");
        }
        if (updateImageStatusEntity.isNotEmpty) {
          await photoSelectionImageStatusDao
              .insertAllImages(updateImageStatusEntity);
        }
      }

      /// DELETE
      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await photoSelectionImageStatusDao.deleteImagesStatus(delete[i]);
        }
      }
    }
  }
}

class ConfirmImageUpsertModel {
  final String eventCode;
  final List<PhotoSelectionImage>? photoSelectionImage;

  ConfirmImageUpsertModel({required this.eventCode, this.photoSelectionImage});
}
