import 'dart:convert';

import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';
import 'package:photomall_studio_manager/api/constants/transporter_constants.dart';

import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import '../objectbox.g.dart';

class StudioController {
/*  Future<void> fillStudioData() async {
    TransporterDao transporterDao = TransporterDao();
    List<appDb.TransportDataData>? transportData =
        await transporterDao.getEventTransporterWhereDataAvailable();
    if (transportData != null && transportData.isNotEmpty) {
      List<appDb.PhotomallStudioInfoCompanion> photomallStudioInfoCompanions =
          [];
      List<appDb.TransportDataCompanion> transportDataCompanions = [];

      for (appDb.TransportDataData transportDatum in transportData) {
        Data studiosDatum = Data.fromJson(json.decode(transportDatum.data!));
        photomallStudioInfoCompanions.add(appDb.PhotomallStudioInfoCompanion(
            code: drift.Value(studiosDatum.code!),
            lastUpdatedAt: drift.Value(studiosDatum.lastUpdatedAt!),
            role: drift.Value(transportDatum.role!),
            value: drift.Value(transportDatum.data!)));

        transportDataCompanions.add(appDb.TransportDataCompanion(
            code: drift.Value(transportDatum.code),
            role: const drift.Value(null),
            data: const drift.Value(null),
            lastUpdatedAt: drift.Value(transportDatum.lastUpdatedAt),
            updateRequired: const drift.Value(0),
            tag: drift.Value(TransporterConstants.studiosData)));
      }
      if (photomallStudioInfoCompanions.isNotEmpty) {
        PhotoMallStudioInfoDao photoMallStudioInfoDao =
            PhotoMallStudioInfoDao();
        await photoMallStudioInfoDao.insertAllStudioInfo(
            infoCompanions: photomallStudioInfoCompanions);
      }
      if (transportDataCompanions.isNotEmpty) {
        /// wipe all previous filled datas
        await transporterDao.insertAllNewTransporter(transportDataCompanions);
      }
    }
  }*/

  Future<void> upsertStudioData() async {
    List< TransportData> deleteTransporterData = [];
    final transporterDao = objectBox.transporterDao;

    List<TransportData>? transportData =
        await transporterDao.getEventTransporterWhereDataAvailable();

    List<String> apiTransporter = [];
    for (TransportData transporter in transportData!) {
      apiTransporter.add(transporter.code);
    }
    List<String> existingStudioInfos = [];
    if (apiTransporter.isNotEmpty) {
      List create = []; // insert this event
      List delete = []; // delete this event
      List update = []; // change update required as true
      /// get local

      final photoMallStudioInfoDao = objectBox.photoMallStudioInfoDao;
      List<PhotomallStudioInfo>? studioInformation =
          await photoMallStudioInfoDao.getAllStudioInfoAvailable();
      if (studioInformation != null && studioInformation.isNotEmpty) {
        for (var studioInfo in studioInformation) {
          existingStudioInfos.add(studioInfo.code);
        }
      }
      for (int i = 0; i < apiTransporter.length; i++) {
        if (existingStudioInfos.contains(apiTransporter[i])) {
          update.add(apiTransporter[i]);
        }
        if (!existingStudioInfos.contains(apiTransporter[i])) {
          create.add(apiTransporter[i]);
        }
      }
      for (int i = 0; i < existingStudioInfos.length; i++) {
        if (!apiTransporter.contains(existingStudioInfos[i])) {
          delete.add(existingStudioInfos[i]);
        }
      }

      /// INSERT New

      if (create.isNotEmpty) {
        List<PhotomallStudioInfo> newInfoEntity = [];
        for (int i = 0; i < create.length; i++) {
          List<TransportData>? newInfos =
              transportData.where((obj) => obj.code == create[i]).toList();
          for (TransportData _newInfo in newInfos) {
            Data studiosDatum = Data.fromJson(json.decode(_newInfo.data!));
            newInfoEntity.add(PhotomallStudioInfo(
                code: studiosDatum.code!,
                lastUpdatedAt: studiosDatum.lastUpdatedAt!,
                role: _newInfo.role!,
                value: _newInfo.data!));

            deleteTransporterData.add(TransportData(
                code: _newInfo.code,
                role: null,
                data:null,
                lastUpdatedAt: _newInfo.lastUpdatedAt,
                updateRequired: 0,
                tag: TransporterConstants.studiosData));
          }
        }
        if (newInfoEntity.isNotEmpty) {
          await photoMallStudioInfoDao.insertAllStudioInfo(newInfoEntity);
        }
      }

      /// UPDATE Existing

      if (update.isNotEmpty) {
        List<PhotomallStudioInfo> updateInfomation = [];
        for (int i = 0; i < update.length; i++) {
          List<TransportData> updateInfos =
              transportData.where((obj) => obj.code == update[i]).toList();
          for (TransportData updateInfo in updateInfos) {
            Data studiosDatum = Data.fromJson(json.decode(updateInfo.data!));
            // ✅ Fetch existing object to get its ObjectBox-assigned ID
            PhotomallStudioInfo? existing =
            await photoMallStudioInfoDao.getStudioInfoWhereCode(updateInfo.code);
            if(existing!=null){
              updateInfomation.add(PhotomallStudioInfo(
                  id: existing.id,
                  code: studiosDatum.code!,
                  lastUpdatedAt: studiosDatum.lastUpdatedAt!,
                  role: updateInfo.role!,
                  value: updateInfo.data!));
            }

            deleteTransporterData.add(TransportData(
                code: updateInfo.code,
                role: null,
                data: null,
                lastUpdatedAt: updateInfo.lastUpdatedAt,
                updateRequired: 0,
                tag: TransporterConstants.studiosData));
          }
        }
        if (updateInfomation.isNotEmpty) {
          await photoMallStudioInfoDao.insertAllStudioInfo(updateInfomation,mode: PutMode.update);
        }
      }

      /// DELETE

      if (delete.isNotEmpty) {
        for (int i = 0; i < delete.length; i++) {
          await transporterDao.deleteTransporterWhereCode(delete[i]);
        }
      }

      if (deleteTransporterData.isNotEmpty) {
        await transporterDao.insertAllNewTransporter(deleteTransporterData);
      }
    }
  }
}
