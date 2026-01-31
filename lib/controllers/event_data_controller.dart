import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:googleapis/driveactivity/v2.dart';
import 'package:objectbox/objectbox.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/add_event_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_confirm_index.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/controllers/photo_selection_controller.dart';
import 'package:photomall_studio_manager/controllers/ps_image_status_controller.dart';
import 'package:photomall_studio_manager/database/dao/event_dao.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';
import 'package:photomall_studio_manager/database/dao/photo_selection_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import '../preference/preference_constants.dart';

class EventController {
  Future<void> upsertEvent(
      List<AddEventResponse> addedEvents, String studioCode,
      {bool isFromEventsPage = false}) async {
    final photoSelectionDao = objectBox.photoSelectionDao;

    List<String> apiEvents = [];
    for (AddEventResponse event in addedEvents) {
      if (event.status == 1) {
        showLog("existingEvents length ${event.code!}");

        apiEvents.add(event.code!);
      }
    }
    List<String> existingEvents = [];
    if (apiEvents.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local
      final eventModelDao = objectBox.eventModelDao;

      List<Events>? eventsAtDB =
          await eventModelDao.getEventWhereStudioCode(studioCode);
      showLog("existingEvents length ${eventsAtDB.length}");

      if (eventsAtDB.isNotEmpty) {
        for (var _event in eventsAtDB) {
          showLog("existingEvents ${_event.code}");
          existingEvents.add(_event.code);
        }
      }
      for (int i = 0; i < apiEvents.length; i++) {
        if (existingEvents.contains(apiEvents[i])) {
          showLog("update Events ${apiEvents[i]}");
          update.add(apiEvents[i]);
        }
        if (!existingEvents.contains(apiEvents[i])) {
          showLog("create Events ${apiEvents[i]}");

          create.add(apiEvents[i]);
        }
      }
      for (int i = 0; i < existingEvents.length; i++) {
        if (!apiEvents.contains(existingEvents[i])) {
          delete.add(existingEvents[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        List<Events> newEventEntity = [];
        List<PhotoSelection> newPhotoSelectionEntity = [];
        List<ConfirmImageUpsertModel> photoSelectionConfirmedIndexs = [];
        int confirmedLastUpdatedAt = 0;
        for (int i = 0; i < create.length; i++) {
          AddEventResponse? newEvent =
              addedEvents.where((obj) => obj.code == create[i]).toList().first;
          if (newEvent.data != null) {
            String? coverImage = getCoverImage(newEvent.data!.screenDisplay!,
                newEvent.data!.jvtFileConnectors!);
            newEventEntity.add(Events(
              screenDisplay: newEvent.data!.screenDisplay ?? 2,
              code: newEvent.code!,
              studioCode: studioCode,
              name: newEvent.data!.name!,
              categoryName: newEvent.data!.categoryName!,
              published: newEvent.data!.published == 1 ? true : false,
              lastUpdatedAt: newEvent.data!.lastUpdatedAt!,
              coverImage: coverImage ?? "",
              userName: newEvent.data!.studioUser?.name ?? "",
              pageNumber: 0,
              createdAt: DateTime.now(),
            ));
          }

          showLog(
              "confirmedUpdateRequired >> ${newEvent.confirmedUpdateRequired}");
          if (newEvent.confirmedUpdateRequired == 1) {
            showLog("confirmedUpdateRequired ===> 1 ${apiEvents[i]}");
            PhotoSelectionConfirmedIndex? photoSelectionConfirmedIndex =
                await callConfirmIndex(newEvent.code!, studioCode);
            if (photoSelectionConfirmedIndex != null) {
              photoSelectionConfirmedIndexs.add(ConfirmImageUpsertModel(
                  eventCode: newEvent.code!,
                  photoSelectionImage:
                      photoSelectionConfirmedIndex.photoSelectionImages));
            }
            confirmedLastUpdatedAt = newEvent.confirmedLastUpdatedAt!;
          }

          if (newEvent.data!.photoselectionCode != null) {
            newPhotoSelectionEntity.add(PhotoSelection(
                code: newEvent.data!.photoselectionCode!,
                eventCode: newEvent.data!.code!,
                lastUpdatedAt: 0,
                confirmedStatus:
                    newEvent.data!.confirmedStatus == 1 ? true : false,
                confirmedLastUpdatedAt: confirmedLastUpdatedAt));
          }
        }
        if (newEventEntity.isNotEmpty) {
          await eventModelDao.insertAllEvents(newEventEntity);
        }
        if (newPhotoSelectionEntity.isNotEmpty) {
          await photoSelectionDao
              .insertAllPhotoSelections(newPhotoSelectionEntity);
        }
        if (photoSelectionConfirmedIndexs.isNotEmpty) {
          await fillConfirmedStratusIndex(photoSelectionConfirmedIndexs);
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        List<Events> updateEventEntity = [];
        List<ConfirmImageUpsertModel> photoSelectionConfirmedIndexs = [];
        int confirmedLastUpdatedAt = 0;
        List<PhotoSelection> updatePhotoSelectionEntity = [];
        for (int i = 0; i < update.length; i++) {
          AddEventResponse? updateEvent =
              addedEvents.where((obj) => obj.code == update[i]).toList().first;
          if (updateEvent.data != null) {
            String? coverImage = getCoverImage(updateEvent.data!.screenDisplay!,
                updateEvent.data!.jvtFileConnectors!);
            updateEventEntity.add(Events(
              pageNumber: 0,
              createdAt: DateTime.now(),
              screenDisplay: updateEvent.data!.screenDisplay ??2,
              code: updateEvent.code!,
              studioCode: studioCode,
              name: updateEvent.data!.name!,
              categoryName: updateEvent.data!.categoryName!,
              published:
                  updateEvent.data!.published == 1 ? true : false,
              lastUpdatedAt: updateEvent.data!.lastUpdatedAt!,
              coverImage: coverImage??'',
              userName: updateEvent.data!.studioUser?.name ?? "",
            ));
            // get local photo selection for this event
            PhotoSelection? photoSelection = await photoSelectionDao
                .getPhotoSelectionWhereEventCode(updateEvent.code!);
            int lastUpdatedat = 0;
            if (photoSelection != null) {
              lastUpdatedat = photoSelection.lastUpdatedAt;
            }
            updatePhotoSelectionEntity.add(PhotoSelection(
                code: updateEvent.data!.photoselectionCode ?? "",
                eventCode: updateEvent.data!.code!,
                lastUpdatedAt: lastUpdatedat,
                confirmedStatus:
                    updateEvent.data!.confirmedStatus == 1 ? true : false,
                confirmedLastUpdatedAt: confirmedLastUpdatedAt));
          }

          showLog(
              "updateEvent confirmedUpdateRequired >>> ${updateEvent.confirmedUpdateRequired}");

          if (updateEvent.confirmedUpdateRequired == 1) {
            PhotoSelectionConfirmedIndex? photoSelectionConfirmedIndex =
                await callConfirmIndex(updateEvent.code!, studioCode);

            if (photoSelectionConfirmedIndex != null) {
              photoSelectionConfirmedIndexs.add(ConfirmImageUpsertModel(
                  eventCode: updateEvent.code!,
                  photoSelectionImage:
                      photoSelectionConfirmedIndex.photoSelectionImages));
            }
            confirmedLastUpdatedAt = updateEvent.confirmedLastUpdatedAt!;
          }
        }
        if (updateEventEntity.isNotEmpty) {
          await eventModelDao.insertAllEvents(updateEventEntity,mode: PutMode.update);
        }
        if (updatePhotoSelectionEntity.isNotEmpty) {
          await photoSelectionDao
              .insertAllPhotoSelections(updatePhotoSelectionEntity);
        }
        if (photoSelectionConfirmedIndexs.isNotEmpty) {
          await fillConfirmedStratusIndex(photoSelectionConfirmedIndexs);
        }
      }

      /// DELETE

      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await eventModelDao.deleteEventsWhereCode(delete[i]);
        }
      }
    }
    PhotoSelectionController photoSelectionController =
        PhotoSelectionController();
    showLog('upsertPhotoSelection');
    (!Platform.isAndroid && isFromEventsPage == false)
        ? await photoSelectionController.upsertPhotoSelection(
            addedEvents, studioCode)
        : null;
  }

  String? getCoverImage(
      int screenDisplay, List<JvtFileConnector> jvtFileConnectors) {
    for (JvtFileConnector jvtFileConnector in jvtFileConnectors) {
      //if (jvtFileConnector.screenDisplay == screenDisplay) {
      return jvtFileConnector.jvtFile!.name;
      //}
    }
    return null;
  }

  Future<String?> getLastUpdated(String eventCode) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the map from SharedPreferences
    String? savedData = prefs.getString(pSConfirmIndexLastUpdatedKey);
    showLog('savedData $savedData');
    if (savedData != null && savedData != '') {
      Map<String, String> eventCodesMap =
          Map<String, String>.from(jsonDecode(savedData));
      return eventCodesMap[eventCode];
    }
    return null;
  }

  Future<void> saveLastUpdate(
      {required String eventCode, required String lastUpdated}) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve existing map from SharedPreferences
    final String? savedData = prefs.getString(pSConfirmIndexLastUpdatedKey);
    Map<String, String> eventCodesMap = savedData != null
        ? Map<String, String>.from(jsonDecode(savedData))
        : {};

    // Update the map with the new event code and last updated value
    eventCodesMap[eventCode] = lastUpdated;

    // Save the updated map back to SharedPreferences
    await prefs.setString(
        pSConfirmIndexLastUpdatedKey, jsonEncode(eventCodesMap));
  }

  Future<PhotoSelectionConfirmedIndex?> callConfirmIndex(
      String eventCode, String studioCode) async {
    if (!Platform.isAndroid) {
      String lastUpdated = await getLastUpdated(eventCode) ?? "";
      showLog('callConfirmIndexPrefs ${lastUpdated == 'null'}');
      Api api = Api(null);
      PhotoSelectionConfirmedIndex? photoSelectionConfirmedIndex =
          await api.photoSelectionConfirmIndexApiCall(
              lastUpdatedAt: (lastUpdated != "null" && lastUpdated != "")
                  ? lastUpdated
                  : '0',
              eventCode: eventCode,
              studioCode: studioCode);
      await saveLastUpdate(
          eventCode: eventCode,
          lastUpdated:
              photoSelectionConfirmedIndex?.lastUpdatedAt.toString() ?? "");
      return photoSelectionConfirmedIndex;
    }
  }

 /* insertEventWhereAddedByUser(
      List<AddEventResponse> eventResponses, String studioCode,
      {bool isFromEventsPage = false}) async {
    List<Events> newEventEntity = [];
    List<appDb.PhotoSelectionsCompanion> newPhotoSelectionEntity = [];
    List<ConfirmImageUpsertModel> confirmImageUpsertModel = [];
    int confirmedLastUpdatedAt = 0;
    final eventModelDao = objectBox.eventModelDao;

    PhotoSelectionDao photoSelectionDao = PhotoSelectionDao();
    for (AddEventResponse _newEvent in eventResponses) {
      if (_newEvent.updateRequired == 1) {
        String? coverImage = getCoverImage(
            _newEvent.data!.screenDisplay!, _newEvent.data!.jvtFileConnectors!);
        showLog('coverImage event is $coverImage');
        newEventEntity.add(Events(
          pageNumber: 0,
            createdAt: DateTime.now(),
            code: _newEvent.code!,
            studioCode: studioCode,
            name: _newEvent.data!.name!,
            categoryName: _newEvent.data!.categoryName!,
            published:
                _newEvent.data!.published == 1 ? true : false,
            lastUpdatedAt: _newEvent.data!.lastUpdatedAt!,
            coverImage:coverImage??'',
            userName: _newEvent.data!.studioUser?.name ?? "",
            screenDisplay: _newEvent.data!.screenDisplay ??2));
        if (_newEvent.data!.photoselectionCode != null) {
          if (_newEvent.confirmedUpdateRequired == 1 &&
              isFromEventsPage == false) {
            showLog('message ---- 3rd');
            PhotoSelectionConfirmedIndex? photoSelectionConfirmedIndex =
                await callConfirmIndex(_newEvent.code!, studioCode);
            if (photoSelectionConfirmedIndex != null) {
              confirmImageUpsertModel.add(ConfirmImageUpsertModel(
                  eventCode: _newEvent.code!,
                  photoSelectionImage:
                      photoSelectionConfirmedIndex.photoSelectionImages));
            }
            confirmedLastUpdatedAt = _newEvent.confirmedLastUpdatedAt!;
          }
          newPhotoSelectionEntity.add(appDb.PhotoSelectionsCompanion(
              code: drift.Value(_newEvent.data!.photoselectionCode!),
              eventCode: drift.Value(_newEvent.data!.code!),
              lastUpdatedAt: const drift.Value(0),
              confirmedStatus: drift.Value(
                  _newEvent.data!.confirmedStatus == 1 ? true : false),
              confirmedLastUpdatedAt: drift.Value(confirmedLastUpdatedAt)));
        }

        if (newEventEntity.isNotEmpty) {
          await eventModelDao.insertAllEvents(newEventEntity);
        }
        if (newPhotoSelectionEntity.isNotEmpty) {
          await photoSelectionDao
              .insertAllPhotoSelections(newPhotoSelectionEntity);
        }
        showLog('confirmImageUpsertModel ${confirmImageUpsertModel.length}');
        if (confirmImageUpsertModel.isNotEmpty) {
          await fillConfirmedStratusIndex(confirmImageUpsertModel);
        }
      }
    }
    PhotoSelectionController photoSelectionController =
        PhotoSelectionController();
    (!Platform.isAndroid && isFromEventsPage == false)
        ? await photoSelectionController.upsertPhotoSelection(
            eventResponses, studioCode)
        : null;
  }*/
  insertEventWhereAddedByUser(
      List<AddEventResponse> eventResponses,
      String studioCode, {
        bool isFromEventsPage = false,
      }) async {
    final eventModelDao = objectBox.eventModelDao;
    final photoSelectionDao = objectBox.photoSelectionDao;

    PhotoSelectionController photoSelectionController = PhotoSelectionController();

    List<PhotoSelection> newPhotoSelectionEntity = [];
    List<ConfirmImageUpsertModel> confirmImageUpsertModel = [];

    for (AddEventResponse _newEvent in eventResponses) {
      if (_newEvent.updateRequired == 1) {
        // Cover Image
        String? coverImage = getCoverImage(
            _newEvent.data!.screenDisplay!,
            _newEvent.data!.jvtFileConnectors!);

        // Check if event already exists
        Events? existing = eventModelDao.getEventWhereCode(_newEvent.code!);

        // Prepare new/updated event
        Events event = Events(
          id: existing?.id ?? 0, // Keep same ID to update, or 0 to insert new
          pageNumber: 0,
          createdAt: DateTime.now(),
          code: _newEvent.code!,
          studioCode: studioCode,
          name: _newEvent.data!.name!,
          categoryName: _newEvent.data!.categoryName!,
          published: _newEvent.data!.published == 1,
          lastUpdatedAt: _newEvent.data!.lastUpdatedAt!,
          coverImage: coverImage ?? '',
          userName: _newEvent.data!.studioUser?.name ?? "",
          screenDisplay: _newEvent.data!.screenDisplay ?? 2,
        );

        // Put (insert or update)
        eventModelDao.insertAllEvents([event]);

        // Photo selection
        if (_newEvent.data!.photoselectionCode != null) {
          int confirmedLastUpdatedAt = 0;
          if (_newEvent.confirmedUpdateRequired == 1 &&
              isFromEventsPage == false) {
            PhotoSelectionConfirmedIndex? confirmedIndex =
            await callConfirmIndex(_newEvent.code!, studioCode);
            if (confirmedIndex != null) {
              confirmImageUpsertModel.add(
                ConfirmImageUpsertModel(
                  eventCode: _newEvent.code!,
                  photoSelectionImage: confirmedIndex.photoSelectionImages,
                ),
              );
            }
            confirmedLastUpdatedAt = _newEvent.confirmedLastUpdatedAt!;
          }

          newPhotoSelectionEntity.add(
            PhotoSelection(
              code: _newEvent.data!.photoselectionCode!,
              eventCode: _newEvent.data!.code!,
              lastUpdatedAt: 0,
              confirmedStatus:
                  _newEvent.data!.confirmedStatus == 1,
              confirmedLastUpdatedAt: confirmedLastUpdatedAt,
            ),
          );
        }
      }
    }

    // Bulk insert photo selections
    if (newPhotoSelectionEntity.isNotEmpty) {
      await photoSelectionDao.insertAllPhotoSelections(newPhotoSelectionEntity);
    }

    // Fill confirm index
    if (confirmImageUpsertModel.isNotEmpty) {
      await fillConfirmedStratusIndex(confirmImageUpsertModel);
    }

    // Desktop call
    if (!Platform.isAndroid && isFromEventsPage == false) {
      await photoSelectionController.upsertPhotoSelection(eventResponses, studioCode);
    }
  }
  fillConfirmedStratusIndex(
      List<ConfirmImageUpsertModel> photoSelectionConfirmedIndexs) async {
    PSImageStatusController psImageStatusController = PSImageStatusController();
    List<PhotoSelectionImageCondition> companion = [];
    showLog(
        'message fill comfirm index ${photoSelectionConfirmedIndexs.length}');

    for (ConfirmImageUpsertModel photoSelectionConfirmedIndex
        in photoSelectionConfirmedIndexs) {
      showLog(
          'message fill confirm for${photoSelectionConfirmedIndex.photoSelectionImage?.length}');

      await psImageStatusController.upsertPhotoSelectionImageStaus(
        photoSelectionConfirmedIndex.photoSelectionImage,
        photoSelectionConfirmedIndex.eventCode,
      );
    }
  }
}
