import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/apiResponseModels/cover_image_response_model.dart';
import '../../api/apiResponseModels/photoSelection_reverse_confirmation_response_model.dart';
import '../../api/apiResponseModels/studio_details_for_studio_settings_response_model.dart';
import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../api/api_call.dart';
import '../../api/constants/key_constants.dart';
import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_elevated_button.dart';
import '../../controllers/app_update_controller.dart';
import '../../generated/l10n.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../../utils/toast_util.dart';
import '../1.constants/common_constants.dart';

class StudioSettingsRouteViewModel extends BaseObserver {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isStudioCoverImageLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isEventCoverImageLoading = ValueNotifier<bool>(false);
  final ProgressController progressController;
  String publicPath = '';
  String studioCoverImage = '';
  String eventCoverImage = '';
  String studioCoverAbleCode = '';
  String eventCoverAbleCode = '';
  String studioName = '';
  String playStoreLink = '';
  String studioCode = '';
  File? selectedFile;
  File? eventSelectedFile;
  Plan? plan;
  Established studioEstablished =
      Established(date: '12', month: '12', year: '1999');
  int i = 0;
  String studioDate = '';
  TransporterResponse? studioData;
  Random random = Random();

  StudioSettingsRouteViewModel(this.progressController);

  List<Package?> packages = [];
  final controller = CropController(
    /// If not specified, [aspectRatio] will not be enforced.
    aspectRatio: null,

    /// Specify in percentages (1 means full width and height). Defaults to the full image.
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  final downloadWithIconController = ValueNotifier<bool>(false);
  bool downloadWithIconValue = false;
  final downloadWithWaterMarkController = ValueNotifier<bool>(false);
  bool downloadWithWaterMarkValue = false;
  final photoSelectionDownloadStatusController = ValueNotifier<bool>(false);
  bool photoSelectionDownloadStatusValue = false;
  final myPhotoDownloadStatusController = ValueNotifier<bool>(false);
  bool myPhotoDownloadStatusValue = false;
  final hideMediaPhotosController = ValueNotifier<bool>(false);
  bool hideMediaValue = false;
  final printPhotosStatusController = ValueNotifier<bool>(false);
  bool printPhotosStatusValue = false;
  final appTourController = ValueNotifier<bool>(false);
  bool appTourValue = false;
  final showPhotosAsRoundedEdgeController = ValueNotifier<bool>(false);
  bool showPhotosAsRoundedEdgeValue = false;
  final usersAllowedInFaceRecognitionController = ValueNotifier<bool>(false);
  bool usersAllowedInFaceRecognitionValue = false;
  final doubtImageClearController = ValueNotifier<bool>(false);
  bool doubtImageClearValue = false;
  final androidAppRedirectionController = ValueNotifier<bool>(false);
  bool androidAppRedirectionValue = false;
  TextEditingController nameController = TextEditingController();
  Api api = Api(null);
  BuildContext? buildContext;
  AppUpdateController appUpdateController = AppUpdateController();
  String appVersion = '';
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialData() async {
    isLoading.value = true;
    notifyListeners();
    studioCode = await PreferenceHelper.getString(studioCodePrefKey);
    await getStudioData();
    await studioDetailsForStudioSettingsApi();

    isLoading.value = false;
    await appUpdateController.checkForAppUpdate(null);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    appVersion = prefs.getString(updateStatusKey) ?? "";
    showLog('studioDetailsForStudioSettingsApi appVersion $appVersion');
    notifyListeners();
  }

  changeStudioName(String editedName) async {
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    showLog('changeStudioName ${studioData!.studiosData![studioIndex].data!.name}');
    var response = await api.studioNameUpdateApiCall(studioName: editedName);
    if (response != null) {
      studioName = editedName;
      studioData!.studiosData![studioIndex].data!.name = editedName;
      await PreferenceHelper.setString(studioDataKey, jsonEncode(studioData));
    }

    notifyListeners();
  }

  getStudioData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    //showLog('res2res2res2res2 ${prefsStudioData}');
    studioData = transporterResponseFromJson(prefsStudioData);

    if (studioData?.studiosData![studioIndex].data != null) {
      studioName = studioData!.studiosData![studioIndex].data!.name ?? '';
      playStoreLink = studioData!.studiosData![studioIndex].data!.playStoreUrl ?? '';
      packages = studioData!.studiosData![studioIndex].data!.packages!;
      publicPath = studioData!.studiosData![studioIndex].data!.publicStoragePath!;
      studioCoverImage = await preferences.getString(studioCoverImageKey) ??
          ""; /*studioData!
          .studiosData![0].data!.jvtFileConnectors![0].jvtFile!.name!;*/
      eventCoverImage =
          await preferences.getString(defaultEventCoverImageKey) ?? "";

      /*studioData!
          .studiosData![0].data!.jvtFileConnectors![3].jvtFile!.name!;*/
     if(studioData!
         .studiosData![studioIndex].data!.jvtFileConnectors!.isNotEmpty) {
       studioCoverAbleCode = studioData!
           .studiosData![studioIndex].data!.jvtFileConnectors![0].jvtFile!
           .code!;
     }   if(studioData!
          .studiosData![studioIndex].data!.jvtFileConnectors!.length>3){
      eventCoverAbleCode = (eventCoverImage != '')
          ? studioData!
              .studiosData![studioIndex].data!.jvtFileConnectors![3].jvtFile!.code!
          : '';
      }
      plan = studioData!.studiosData![studioIndex].data!.plan;
      showLog('getStudioData in 1 -->$studioCoverImage}');
    }
  }

  studioSettingsUpdateApi({required Map<String, dynamic> map}) async {
    map.addAll({
      studioCodeKey: studioCode,
    });

    PhotoselectionReverseConfirmationResponseModel? res =
        await api.studioSettingsApiCall(map: map, studioCode: studioCode);
    showLog('studioSettingsUpdateApi $res');
  }

  studioDetailsForStudioSettingsApi() async {
    showLog('studioDetailsForStudioSettingsApi $studioCode');
    StudioDetailsForStudioSettingsResponseModel? studioSettings =
        await api.studioDetailsForStudioSettingsApiCall(studioCode: studioCode);

    if (studioSettings != null) {
      studioEstablished = studioSettings.studioDetails![0].established ??
          Established(date: '12', month: '12', year: '1999');
      DefaultSettings? settings =
          studioSettings.studioDetails![0].defaultSettings;
      downloadWithIconValue = (settings!.downloadWithIcon == 1) ? true : false;
      downloadWithWaterMarkValue =
          (settings.downloadWithWatermark == 1) ? true : false;
      photoSelectionDownloadStatusValue =
          (settings.downloadAllPhotoselectionImages == 1) ? true : false;
      myPhotoDownloadStatusValue =
          (settings.myPhotosDownloadable == 1) ? true : false;
      hideMediaValue = (settings.hideMediaPhotos == 1) ? true : false;
      printPhotosStatusValue = (settings.photosPrintStatus == 1) ? true : false;
      appTourValue = (settings.appTour == 1) ? true : false;
      showPhotosAsRoundedEdgeValue =
          (settings.showPhotosAsRoundedEdge == 1) ? true : false;
      usersAllowedInFaceRecognitionValue =
          (settings.usersAllowedPerAccountInFaceRecognition == 1)
              ? true
              : false;
      doubtImageClearValue = (settings.doubtImageClear == 1) ? true : false;
      androidAppRedirectionValue =
          (settings.forbiddenAppRedirect == 1) ?false  : true;
    }
  }

  setStudioCoverImage(File image, BuildContext context,
      {isFromEvent = false}) async {
    showLog('setStudioCoverImage ${image.path}');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    (isFromEvent) ? selectedFile = null : eventSelectedFile = null;
    String? base64Image;
    try {
      base64Image = base64Encode(await image!.readAsBytes());
      CoverImageResponseModel? response = await api.coverImageUpdateApiCall(
          studioCode: studioCode,
          ableCode: (isFromEvent) ? eventCoverAbleCode : studioCoverAbleCode,
          fileName:
              (isFromEvent) ? 'default-event-cover-image' : 'studio-cover',
          imageInBase64: base64Image);
      if (response != null) {
        showLog('res $response');
        await preferences.setString(
            (isFromEvent) ? defaultEventCoverImageKey : studioCoverImageKey,
            response.jvtFileConnector!.jvtFile!.name!);
        (Platform.isAndroid)
            ? Fluttertoast.showToast(
                msg: 'Image Updated Successfully' ?? "",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 18,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0)
            : ToastUtil.showSnackBarAtCurrentState(
                'Image Updated Successfully',
                seconds: 8,
              );
      }
      showLog('base64Image base64Image');
      if (isFromEvent == false) {
        selectedFile = image;
      } else {
        eventSelectedFile = image;
      }
    } catch (e) {
      showLog('jvtFileConnector $e');
      (Platform.isAndroid)
          ? Fluttertoast.showToast(
              msg: 'Can\'t update image' ?? "",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 18,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0)
          : ToastUtil.showSnackBarAtCurrentState(
              'Can\'t update Image ',
              seconds: 8,
            );
    }

    (isFromEvent)
        ? isEventCoverImageLoading.value = false
        : isStudioCoverImageLoading.value = false;
    notifyListeners();
  }

  showImageCropAlertDialog(PickedFile image, BuildContext context,
      {isFromEvent = false}) {
    buildContext = context;
    return showDialog(
        context: context,
        builder: (context) {
          return CommonAlertDialog(
            title: isFromEvent
                ? S.of(context).event_cover_image
                : S.of(context).studio_cover_image,
            contentWidget: Column(
              children: [
                SizedBox(
                  height: 300,
                  width: 700,
                  child: CropImage(
                    controller: controller,
                    image: Image.file(File(image.path)),
                    paddingSize: 0.0,
                    alwaysMove: true,
                    minimumImageSize: 100,
                    maximumImageSize: 700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: _buildButtons(context),
                )
              ],
            ),
            actions: [
              CommonElevatedButton(
                onTap: () async {
                  (isFromEvent)
                      ? isEventCoverImageLoading.value = true
                      : isStudioCoverImageLoading.value = true;
                  notifyListeners();
                  Navigator.pop(context);
                  // Get the cropped bitmap
                  Directory directory = await getApplicationCacheDirectory();
                  i = random.nextInt(100);
                  // Specify the file path
                  String filePath = '${directory.path}/cropped_image$i.png';
                  File file = File(filePath);
                  if (await file.exists()) {
                    // filePath = '${directory.path}/cropped_image${i++}.png';
                    await file.delete();
                    showLog('Deleted existing file at: $filePath');
                  }
                  ui.Image bitmap = await controller.croppedBitmap();

                  ByteData? data =
                      await bitmap.toByteData(format: ui.ImageByteFormat.png);
                  Uint8List bytes = data!.buffer.asUint8List();

                  await file.writeAsBytes(bytes, flush: true);
                  // Ensure that the bitmap was cropped successfully
                  if (bitmap != null) {
                    // Call the method to handle the image
                    await setStudioCoverImage(file, context,
                        isFromEvent: isFromEvent);
                  } else {
                    // Handle the case where cropping failed (optional)
                    showLog('Failed to crop the image');
                  }
                },
                text: isFromEvent
                    ? S.of(context).set_event_cover_image
                    : S.of(context).set_studio_cover_image,
              ),
              CommonElevatedButton(
                onTap: () => Navigator.pop(context),
                text: S.of(context).cancel,
              ),
            ],
          );
        });
  }

  Widget _buildButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.rotation = CropRotation.up;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              controller.aspectRatio = null;
            },
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
          ),
          /*TextButton(
        onPressed: _finished,
        child: const Text('Done'),
      ),*/
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: buildContext!,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            /*   SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),*/
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _finished() async {
    final image = await controller.croppedImage();
    if (buildContext!.mounted) {
      await showDialog<bool>(
        context: buildContext!,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(6.0),
            titlePadding: const EdgeInsets.all(8.0),
            title: const Text('Cropped image'),
            children: [
              Text('relative: ${controller.crop}'),
              Text('pixels: ${controller.cropSize}'),
              const SizedBox(height: 5),
              image,
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
