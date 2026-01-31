import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/studio_store_model.dart'
    as storeResponse;
import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/user_staf_index_response_model.dart'
    as userindex;
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/constants/transporter_constants.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/login/register_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/apiResponseModels/download_extension_response_model.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../main.dart';
import '../../preference/preference_helper.dart';

class StudioListController extends BaseObserver {
  BuildContext? context;
  bool isLoading = false;
  bool isHover = false;
  List<StudioView> studios = [];
  List<String> extension = [];
  String? publicPath = '';

  StudioListController({this.context});

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialValues() async {
    isLoading = true;
    setBusy(false);
    await callStudioIndex();
    isLoading = false;
    setBusy(false);
  }

  Future<void> callStudioIndex() async {
    await callResourcesFromApi();
    await getResourcesFromDatabase();
  }

  String getExtensionString(List<Datum>? extension) {
    String exe = jsonEncode(extension!.map((e) {
      return e.toJson();
    }).toList());
    showLog("extension : $exe");
    return exe;
  }

  callResourcesFromApi() async {
    var prefs = await SharedPreferences.getInstance();
    DownloadExtensionIndexModel? response =
        await Api(context!).downloadExtensionIndexApiCall();
    if (response != null || response?.data != null) {
      for (int i = 0; i < response!.data.length; i++) {
        extension.add(response.data[i].extension);
      }
      showLog('extension is $extension');

      await prefs.setStringList(downloadExtensionKey, extension);

      /* await PreferenceHelper.setString(
            downloadExtensionKey, getExtensionString(response.data));*/
    }
    userindex.UserStaffGroupsIndex? userStaffGroupsIndex =
        await Api(context!).userStaffIndexApiCall();
    if (userStaffGroupsIndex != null && userStaffGroupsIndex.data!.isEmpty) {
      StudioStore(
        context!,
        (studio, email) async {
          List<TransportData> transportDataCompanion = [];

          storeResponse.StudioStoreresponse? studioStore =
              await Api(context!).studioStoreApiCall(studio, email);
          if (studioStore != null && studioStore.data!.isNotEmpty) {
            for (storeResponse.Datum datum in studioStore.data!) {
              transportDataCompanion.add(TransportData(
                  role: datum.role,
                  data: null,
                  tag: TransporterConstants.studiosData,
                  code: datum.studioRandomId!,
                  lastUpdatedAt: 0,
                  updateRequired: 1));
            }
            final transporterDao =objectBox.transporterDao;

            if (transportDataCompanion.isNotEmpty) {
              await transporterDao
                  .insertAllNewTransporter(transportDataCompanion);
            }
          }
        },
      );
    } else {
      List<TransportData> transportDataCompanion = [];
      //userStaffGroupsIndex
      for (userindex.Datum datum in userStaffGroupsIndex!.data!) {
        transportDataCompanion.add(TransportData(
            role: datum.role,
            data: null,
            tag: TransporterConstants.studiosData,
            code: datum.studioRandomId!,
            lastUpdatedAt: 0,
            updateRequired: 1));
      }
      final transporterDao =objectBox.transporterDao;

      if (transportDataCompanion.isNotEmpty) {
        await transporterDao.insertAllNewTransporter(transportDataCompanion);
      }
    }
  }

  getResourcesFromDatabase() async {
    studios.clear();
    final photoMallStudioInfoDao = objectBox.photoMallStudioInfoDao;
    List<PhotomallStudioInfo>? studioInfos =
        await photoMallStudioInfoDao.getAllStudioInfoAvailable();
    showLog("getResourcesFromDatabase 1 objectBox: $studioInfos");
    if (studioInfos.isNotEmpty) {
      for (PhotomallStudioInfo info in studioInfos) {
        Data studiosDatum = Data.fromJson(json.decode(info.value));
        publicPath = studiosDatum.publicStoragePath!;
        await PreferenceHelper.setString(eventCodePreferenceKey, studiosDatum.code ?? '');

        String coverName = '';
        if (studiosDatum.jvtFileConnectors != null &&
            studiosDatum.jvtFileConnectors!.isNotEmpty) {
          coverName = studiosDatum.jvtFileConnectors![0].jvtFile!.name!;
        }

        studios.add(StudioView(
          code: studiosDatum.code!,
          role: info.role,
          name: studiosDatum.name!,
          imageURL: coverName,
          //  email: getEmail(studiosDatum.contactPoints!),
          //  phone: getPhoneNumber(studiosDatum.contactPoints!)
        ));
      }
    }
  }

  String getPhoneNumber(List<ContactPoint> contactPoints) {
    if (contactPoints.isNotEmpty) {
      if (contactPoints[0].phones != null &&
          contactPoints[0].phones!.isNotEmpty) {
        return contactPoints[0].phones![0].phoneNumber!;
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  String getEmail(List<ContactPoint> contactPoints) {
    if (contactPoints.isNotEmpty) {
      if (contactPoints[0].emails != null &&
          contactPoints[0].emails!.isNotEmpty) {
        return contactPoints[0].emails![0].address!;
      } else {
        return "";
      }
    } else {
      return "";
    }
  }
}

class StudioView {
  final String code;
  final String name;
  final String? role;
  final String? phone;
  final String? email;
  final String imageURL;

  StudioView(
      {required this.name,
      this.role,
      this.phone,
      this.email,
      required this.code,
      required this.imageURL});
}

class Extension {
  String code;
  String extension;

  Extension({
    required this.code,
    required this.extension,
  });
}
