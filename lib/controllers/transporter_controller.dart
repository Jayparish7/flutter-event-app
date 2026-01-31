import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/api/apiRequestModels/transporter_request_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/constants/transporter_constants.dart';
import 'package:photomall_studio_manager/controllers/studio_controller.dart';
import 'package:photomall_studio_manager/database/dao/transporter_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/main.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../api/apiResponseModels/add_event_response_model.dart';
import '../database/object_box_model/object_box_models.dart';
import '../preference/preference_constants.dart';
import 'package:photomall_studio_manager/api/apiRequestModels/add_event_request_model.dart'
    as request;

import 'event_data_controller.dart';

class TransporterController {
  callTransporterApi(int studioIndex) async {
    final transporterDao =objectBox.transporterDao;
    List<InputDatum>? inputData = [];
    List<Studio>? studios = [];

    /// step 1 : get transporter where update required one
    List<TransportData> transporterData =
        await transporterDao.getEventTransporterWhereUpdateRequiredOne();

    /// step 2 : form api structure and call transporter API
    if (transporterData.isNotEmpty) {
      for (TransportData transporterDatum in transporterData) {
        if (transporterDatum.tag == TransporterConstants.studiosData) {
          studios.add(Studio(
              code: transporterDatum.code,
              lastUpdatedAt: transporterDatum.lastUpdatedAt));
        }
      }
      if (studios.isNotEmpty) {
        inputData.add(InputDatum(
            key: TransporterConstants.studiosData, studios: studios));
      }

      if (inputData.isNotEmpty) {
        Map<String, dynamic> data =
            TransporterRequest(inputData: inputData).toJson();
        Api api = Api(null);
        TransporterResponse? transporterResponse =
            await api.transporterApiCall(data);

        /// step 3 : fill all data in trans porter table data column
        /// step 4 : toggle update required to zero
        if (transporterResponse != null &&
            transporterResponse.studiosData!.isNotEmpty) {
          await PreferenceHelper.setString(studioCodePrefKey,
              transporterResponse.studiosData![studioIndex].data!.code!);

          await PreferenceHelper.setString(
              studioDataKey, jsonEncode(transporterResponse));
          try {
            showLog(
                'transporterResponse.studiosData![ ${transporterResponse.studiosData![studioIndex].data!.jvtFileConnectors!.length}');
            if (transporterResponse.studiosData![studioIndex].data!
                    .jvtFileConnectors!.length ==
                4) {
              await PreferenceHelper.setString(
                  defaultEventCoverImageKey,
                  transporterResponse.studiosData![studioIndex].data!
                          .jvtFileConnectors![3].jvtFile!.name ??
                      "");
            }
            showLog(
                'transporterResponse.${transporterResponse.studiosData![studioIndex].data!.jvtFileConnectors!}');
            if (transporterResponse.studiosData![studioIndex].data!
                .jvtFileConnectors!.isNotEmpty) {
              await PreferenceHelper.setString(
                  studioCoverImageKey,
                  transporterResponse.studiosData![studioIndex].data!
                      .jvtFileConnectors![0].jvtFile!.name!);
            }
          } catch (e, s) {
            showLog('message $e $s');
          }

          List<TransportData> transportDataCompanion = [];
          for (StudiosDatum studiosDatum in transporterResponse.studiosData!) {
            /*showLog(
                'studiosDatum.data!.jvtFileConnectors!.length ${studiosDatum.data!.jvtFileConnectors!.length}');
            await PreferenceHelper.setString(studioLogoKey, 'jvtFile!.name}');

            for (int i = 0;
                i < studiosDatum.data!.jvtFileConnectors!.length;
                i++) {
              if (studiosDatum.data!.jvtFileConnectors![i].jvtFile!.name !=
                  null) {
                await PreferenceHelper.setString(studioLogoKey,
                    '${studiosDatum.data!.jvtFileConnectors![i].jvtFile!.name}');
              }
            }*/

            if (studiosDatum.updateRequired == 1) {
              transportDataCompanion.add(TransportData(
                  code: studiosDatum.code!,
                  tag: TransporterConstants.studiosData,
                  lastUpdatedAt: studiosDatum.lastUpdatedAt!,
                  role: transporterData
                      .where((element) => element.code == studiosDatum.code)
                      .first
                      .role,
                  data: studiosDatum.data == null
                      ? null
                      : jsonEncode(studiosDatum.data!.toJson()),
                  updateRequired:  0));
            }
          }
          await transporterDao.insertAllNewTransporter(transportDataCompanion);
        }
      }
    }
    StudioController studioController = StudioController();
    await studioController.upsertStudioData();
  }


}
