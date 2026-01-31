import 'package:photomall_studio_manager/api/apiResponseModels/add_event_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_response_model.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/controllers/folder_controller.dart';
import 'package:photomall_studio_manager/controllers/ps_image_status_controller.dart';
import 'package:photomall_studio_manager/database/dao/photo_selection_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import '../api/apiRequestModels/add_event_request_model.dart';
import '../api/apiResponseModels/photo_selection_confirm_index.dart';
import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import 'event_data_controller.dart';

class PhotoSelectionController {
  Api apiCall = Api(null);
  EventController eventController = EventController();

  Future<void> upsertPhotoSelection(
      List<AddEventResponse>? addedEvents, String studioCode) async {
    // get photo selections from db
    FolderController folderController = FolderController();
    final photoSelectionDao = objectBox.photoSelectionDao;

    showLog('addedEvents $addedEvents ');

   if(addedEvents!=null) {
      for (AddEventResponse addEventResponse in addedEvents) {
        // get photo selections from db
       PhotoSelection? photoSelection = await photoSelectionDao
            .getPhotoSelectionWhereEventCode(addEventResponse.code!);
        showLog('upsertPhotoSelection ${photoSelection?.lastUpdatedAt}');

        if (photoSelection != null) {
          PhotoSelectionResponse? photoSelectionResponse;
          try {
            photoSelectionResponse = await apiCall.photoSelectionApiCall(
                photoSelection.eventCode,
                studioCode,
                photoSelection.lastUpdatedAt);
          } catch (e,s) {
            showLog('message controller $e $s');
            //ToastUtil.showSnackBarAtCurrentState('Something went wrong',seconds: 6);
          }
          if (photoSelectionResponse != null &&
              photoSelectionResponse.updateRequired == 1) {
            showLog(
                'photoSelectionResponse.photoSelectionData ${photoSelectionResponse?.lastUpdatedAt}');
            await fillPhotoSelection(
                photoSelectionResponse.photoSelectionData,
                addEventResponse.code!,
                studioCode,
                photoSelectionResponse!.lastUpdatedAt!);
            await folderController.upsertFolders(
                photoSelectionResponse.photoSelectionData!.folders,
                addEventResponse.code!);
          }
        }
      }
    }else{
     // if(events!=null && events.isNotEmpty){
     //   List<ConfirmImageUpsertModel> photoSelectionConfirmedIndexs = [];
     //
     //    for (appDb.Event event in events) {
     //      // get photo selections from db
     //      PhotoSelection? photoSelection = await photoSelectionDao
     //          .getPhotoSelectionWhereEventCode(event.code);
     //      showLog('upsertPhotoSelection uni ${photoSelection?.lastUpdatedAt}');
     //
     //      if (photoSelection != null) {
     //        PhotoSelectionResponse? photoSelectionResponse;
     //        try {
     //          PhotoSelectionConfirmedIndex? photoSelectionConfirmedIndex =
     //          await eventController.callConfirmIndex(event.code!, studioCode);
     //          if (photoSelectionConfirmedIndex != null) {
     //
     //            photoSelectionConfirmedIndexs.add(ConfirmImageUpsertModel(
     //                eventCode: event.code!,
     //                photoSelectionImage:
     //                photoSelectionConfirmedIndex.photoSelectionImages));
     //          }
     //          photoSelectionResponse = await apiCall.photoSelectionApiCall(
     //              photoSelection.eventCode,
     //              studioCode,
     //              photoSelection.lastUpdatedAt);
     //        } catch (e,s) {
     //          showLog('message controller 1 $e $s');
     //          //ToastUtil.showSnackBarAtCurrentState('Something went wrong',seconds: 6);
     //        }
     //        if (photoSelectionResponse != null &&
     //            photoSelectionResponse.updateRequired == 1) {
     //          showLog(
     //              'photoSelectionResponse.photoSelectionData ${photoSelectionResponse?.lastUpdatedAt}');
     //          await fillPhotoSelection(
     //              photoSelectionResponse.photoSelectionData,
     //              event.code,
     //              studioCode,
     //              photoSelectionResponse!.lastUpdatedAt!);
     //          await folderController.upsertFolders(
     //              photoSelectionResponse.photoSelectionData!.folders,
     //              event.code);
     //        }
     //      }
     //
     //    }
     //    if (photoSelectionConfirmedIndexs.isNotEmpty) {
     //      await eventController.fillConfirmedStratusIndex(photoSelectionConfirmedIndexs);
     //    }
     //  }
     
    }
  }

  Future<void> fillPhotoSelection(PhotoSelectionData? photoSelectionApi,
      String eventCode, String studioCode, int lastUpdated) async {
    showLog("the fillPhotoSelection step 1 $lastUpdated");
    showLog("fillResponse  step 2 new ${photoSelectionApi?.lastUpdatedAt}" );

    // get photo selection by event code
    final photoSelectionDao = objectBox.photoSelectionDao;

   PhotoSelection? photoSelection =
        await photoSelectionDao.getPhotoSelectionWhereEventCode(eventCode);
    if (photoSelection != null) {
      showLog("the fillPhotoSelection step 2 ");

      if (photoSelectionApi != null) {
        showLog("the fillPhotoSelection step 3 ");

        // update
        await photoSelectionDao.insertAllPhotoSelections([
          PhotoSelection(
              code: photoSelectionApi.code!,
              eventCode:eventCode,
              published:
                  photoSelectionApi.published == 1 ? true : false,
              confirmedStatus:
                  photoSelectionApi.confirmedStatus == 1 ? true : false,
              lastUpdatedAt: lastUpdated ??0)
        ]);
      } else {
        showLog("the fillPhotoSelection step 4 ");

        photoSelectionDao.deletePhotoSelectionsWhereCode(photoSelection.code);
      }
    } else {
      showLog("the fillPhotoSelection step  5 ");

      // insert
      if (photoSelectionApi != null) {
        showLog("the fillPhotoSelection step  6 ");

        await photoSelectionDao.insertAllPhotoSelections([
          PhotoSelection(
              code: photoSelectionApi.code!,
              eventCode: eventCode,
              published:
                  photoSelectionApi.published == 1 ? true : false,
              confirmedStatus:
                  photoSelectionApi.confirmedStatus == 1 ? true : false,
              lastUpdatedAt: photoSelectionApi.lastUpdatedAt!)
        ]);
      }
    }
  }
}
