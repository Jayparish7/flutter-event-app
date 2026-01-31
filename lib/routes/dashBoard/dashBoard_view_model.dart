import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/apiResponseModels/dash_board_details_response_model.dart';
import '../../api/apiResponseModels/download_extension_response_model.dart';
import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../api/api_call.dart';
import '../../api/constants/transporter_constants.dart';
import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/file_info_card.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../../utils/toast_util.dart';
import '../1.constants/common_constants.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/user_staf_index_response_model.dart'
    as userindex;
import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/api/apiResponseModels/studio_store_model.dart'
    as storeResponse;

import '../1.constants/route_constants.dart';
import '../login/register_form.dart';
import '../studioList/studio_list_controller.dart';

class DashBoardViewModel extends BaseObserver {
  BuildContext? context;
  Api api = Api(null);
  final ProgressController progressController;
  TransporterResponse? studioData;
  List<String> domainUrls = [''];
  String playStoreUrl = '';
  String shortUrl = '';
  String publicPath = '';
  String studioName = '';
  String domainLink = '';
  String studioCode = '';
  bool isLoading = false;
  bool isHovered = false;
  bool isHovered1 = false;
  List<String> downloadSize = ['500'];
  List<String> sizeList = [
    '500 x 500',
    '100 x 100',
    '200 x 200',
    '1000 x 1000',
    '1500 x 1500',
    '2000 x 2000',
  ];
  List<String> extension = [];
  List<StudioView> studios = [];
  List<CloudStorageInfo> dashboardData = [];
  bool isMultiStudio = false;

  DashBoardViewModel({
    this.context,
    required this.progressController,
  });

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialData(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    var isStudio = await PreferenceHelper.getBool(studioDetectedKey);
    studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    showLog('isStudio $isStudio');
    (!isStudio) ? await callStudioIndex() : null;
    try {
      await getStudioData();
      await dashBoardDetailsApiCall(context);
    } catch (e, s) {
      showLog("try dashBoardDetailsApiCall $e $s");
    }
    isLoading = false;
    notifyListeners();
  }

  getStudioData() async {
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    showLog('res2res2res2res2 $prefsStudioData');
    try {
      if (prefsStudioData != '') {
        studioData = transporterResponseFromJson(prefsStudioData);
      }
    } catch (e) {
      showLog("studioData error $e");
    }
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!
            .studiosData![studioIndex].data!.jvtFileConnectors!.isNotEmpty) {
      domainUrls = [studioData!.studiosData![studioIndex].data!.domainUrl!];
      playStoreUrl = studioData!.studiosData![studioIndex].data!.playStoreUrl!;
      shortUrl = studioData!.studiosData![studioIndex].data!.shortUrl!;
      publicPath =
          studioData!.studiosData![studioIndex].data!.publicStoragePath ?? "";
      domainLink = studioData!.studiosData![studioIndex].data!.ptmlDomain!;
      studioName = studioData!.studiosData![studioIndex].data!.name!;

      await PreferenceHelper.setBool(studioDetectedKey, true);
      showLog('studioName $studioName');
    }
  }

  dashBoardDetailsApiCall(BuildContext context) async {
    if (studioCode != '') {
      DashBoardDetailsResponseModel? data =
          await api.dashBoardDetailsApiCall(studioCode: studioCode);
      if (data != null) {
        Studio detailData = data.studio!;
        await PreferenceHelper.setInt(
            eventsCountPreferenceKey, detailData.eventsCount ?? 0);

        showLog('data ===>$detailData');
        if (!context.mounted) return;

        dashboardData.add(CloudStorageInfo(
          title: S.of(context).users,
          numOfFiles: detailData.usersCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/users.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).events,
          numOfFiles: detailData.eventsCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/events.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).event_with_ps,
          numOfFiles: detailData.eventWithPhotoSelectionsCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/eventWithPs.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).confirmed_photo_selections,
          numOfFiles: detailData.confirmedPhotoselections!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/confirmedPhotoselections.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).unconfirmed_photo_selections,
          numOfFiles: detailData.unconfirmedPhotoselections!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/unconfirmedPhotoselections.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).event_with_photos,
          numOfFiles: detailData.eventsWithPhotosCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/eventWithPhotos.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).event_with_EAlbum,
          numOfFiles: detailData.eventsWithEAlbumCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/eventWithEAlbum.png",
        ));
        dashboardData.add(CloudStorageInfo(
          title: S.of(context).event_with_videos,
          numOfFiles: detailData.eventsWithVideosCount!,
          color: const Color(photomallYellow),
          svgSrc: "assets/images/eventsWithVideos.png",
        ));
      }
    } else {
      showLog("studio code is empty");
    }
  }

  Future<void> downloadQrCode(String data, int size, String qrName) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: Colors.white,
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
        emptyColor: Colors.black, // White background for QR code
      );

      // Generate the image data with the specified size
      final picData = await painter.toImageData(size.toDouble());
      final buffer = picData!.buffer.asUint8List();

      // Get the directory to save the file
      final directory = await getDownloadsDirectory();
      final path = directory!.path;
      final file = File('$path/$qrName-qr_code_${size}x$size.png');

      // Write the image data to the file
      await file.writeAsBytes(buffer);
      ToastUtil.showSnackBarAtCurrentState(
          'Downloaded successfully to $path/$qrName-qr_code_${size}x$size.png',
          seconds: 5,
          actions: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                if (Platform.isWindows) {
                  await Process.run('explorer', [path]);
                } else if (Platform.isMacOS) {
                  await Process.run('open', [path]);
                } else if (Platform.isLinux) {
                  await Process.run('xdg-open', [path]);
                }
              }));
      showLog('Downloaded successfully to $path/qr_code_${size}x$size.png');
    } catch (e) {
      showLog('Error: $e');
    }
  }

  Future<void> callStudioIndex() async {
    await callResourcesFromApi();
    await getResourcesFromDatabase();
  }

  callResourcesFromApi() async {
    var prefs = await SharedPreferences.getInstance();
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    bool isStudioSelected = await PreferenceHelper.getBool(studioSelectedKey);
    showLog('studioIndex is $studioIndex');
    DownloadExtensionIndexModel? response =
        await Api(context).downloadExtensionIndexApiCall();
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
        await Api(context).userStaffIndexApiCall();
    if (!isStudioSelected && userStaffGroupsIndex!.data!.length > 1) {
      Navigator.pushNamed(context!, RoutePaths.studioList);
      return;
    }

    if (userStaffGroupsIndex != null && userStaffGroupsIndex.data!.isEmpty) {
      StudioStore(
        context!,
        (studio, email) async {
          List<TransportData> transportDataCompanion = [];

          storeResponse.StudioStoreresponse? studioStore =
              await Api(context!).studioStoreApiCall(studio, email);
          if (studioStore != null && studioStore.data!.isNotEmpty) {
            showLog("studioStore $studioStore");
            for (storeResponse.Datum datum in studioStore.data!) {
              transportDataCompanion.add(TransportData(
                  role: datum.role,
                  data: null,
                  tag: TransporterConstants.studiosData,
                  code: datum.studioRandomId!,
                  lastUpdatedAt: 0,
                  updateRequired: 1));
            }
            final transporterDao = objectBox.transporterDao;

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
      final transporterDao = objectBox.transporterDao;

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
    showLog("getResourcesFromDatabase objectBox: ${studioInfos.first.code}");
    if (studioInfos!.isNotEmpty) {
      for (PhotomallStudioInfo info in studioInfos) {
        Data studiosDatum = Data.fromJson(json.decode(info.value));
        publicPath = studiosDatum.publicStoragePath!;
        String coverName = '';
        await PreferenceHelper.setString(
            eventCodePreferenceKey, studiosDatum.code ?? '');

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
}
