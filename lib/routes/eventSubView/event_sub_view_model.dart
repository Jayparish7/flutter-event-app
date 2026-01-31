import 'dart:io';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/photo_selection_response_model.dart' as model;
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/controllers/folder_controller.dart';
import 'package:photomall_studio_manager/controllers/image_controller.dart';
import 'package:photomall_studio_manager/controllers/photo_selection_controller.dart';
import 'package:photomall_studio_manager/database/dao/event_dao.dart';
import 'package:photomall_studio_manager/database/dao/folder_dao.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';
import 'package:photomall_studio_manager/database/dao/photo_selection_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/file_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/apiResponseModels/add_event_response_model.dart';
import '../../common_widgets/alert_dialog.dart';
import '../../common_widgets/common_elevated_button.dart';
import '../../controllers/event_data_controller.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../main.dart';
import '../../utils/notification_utils.dart';
import 'package:photomall_studio_manager/api/apiRequestModels/add_event_request_model.dart'
    as request;

class EventSubViewController extends BaseObserver {
  bool isLoading = false;
  bool isLoadingForGetSelectedImages = false;
  NotificationUtils notificationUtils = NotificationUtils();
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;
  String eventCode = "";
  String eventName = "";
  String categoryName = "";
  String studioCode = "";
  bool getListButton = false;
  bool isAddPhotoSelection = false;
  final photoSelectionDao = objectBox.photoSelectionDao;

  String listPath = '';
  FileUtil fileUtil = FileUtil();
  final eventModelDao = objectBox.eventModelDao;

  final folderModelDao = objectBox.folderModelDao;


  List<Events> events = [];
  List<String> extensionList = [];
  String? customSegregationFormat;
  String? customSegregationPath;
  List<String?> missedImages = [];
  final controller = SideMenuController();
  int selectedIndex = (Platform.isAndroid) ? 1 : 1;
  bool? error = false;

  EventSubViewController({
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialValues(String eventCodeValue, String studioCodeValue) async {
    isLoading = true;
    setBusy(false);
    eventCode = eventCodeValue;
    studioCode = studioCodeValue;
    events = await eventModelDao.getEventWhereStudioCode(studioCodeValue);
    await getEventName();
    await getcategoryName();
    (!Platform.isAndroid)
        ? await updatePhotoSelectionData(eventCode, studioCode)
        : null;
    await checkPhotoSelectionConfirmStatus(eventCode);
    await getExtensionList();
    isLoading = false;
    setBusy(false);
  }

  updatePhotoSelectionData(String eventCode, String studioCode) async {
    try {
      // call photo selection data if any update
      List<request.Event> events = [];
      events.add(request.Event(
          code: eventCode, lastUpdatedAt: 0, confirmedLastUpdated_at: 0));
      request.AddEventRequest addEventRequest =
          request.AddEventRequest(studioCode: studioCode, events: events);
      List<AddEventResponse>? eventResponse =
          await apiRepo!.addEventApiCall(addEventRequest.toJson());
      showLog('eventResponse request.AddEventRequest event subview');
      if (eventResponse != null && eventResponse.isNotEmpty) {
        if (eventResponse[0].status == 1) {
          EventController eventController = EventController();
          await eventController.insertEventWhereAddedByUser(
              eventResponse, studioCode,
              isFromEventsPage: false);
        }
      }
      PhotoSelection? photoSelection =
          await photoSelectionDao.getPhotoSelectionWhereEventCode(eventCode);
      showLog(
          'updatePhotoSelectionData in event subView list $photoSelection ');
      if (photoSelection?.code == '') {
        showLog('photoSelection?.code ');
      }
      if (photoSelection != null) {
        model.PhotoSelectionResponse? photoSelectionResponse = await apiRepo!
            .photoSelectionApiCall(
                eventCode, studioCode, photoSelection.lastUpdatedAt);
        await fillResponse(photoSelectionResponse);
      } else {
        //  await fillResponse(photoSelectionResponse);

        isAddPhotoSelection = true;
        notifyListeners();
      }
    } catch (e) {
      showLog('message $e');
    }
  }

  getExtensionList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    extensionList = prefs.getStringList(downloadExtensionKey) ?? [];

    showLog('getExtensionList are $extensionList');
  }

  addPhotoSelection() async {
    isLoading = true;
    notifyListeners();
    model.PhotoSelectionResponse? photoSelectionResponse =
        await apiRepo!.photoSelectionStoreApiCall(eventCode, studioCode, 0);
    String deviceID = await PreferenceHelper.getString(deviceIdPreferenceKey);
    await fillResponse(photoSelectionResponse, deviceID: deviceID);

    await getInitialValues(
      eventCode,
      studioCode,
    );
    isAddPhotoSelection = false;
    notifyListeners();
  }

  fillResponse(model.PhotoSelectionResponse? photoSelectionResponse,
      {String? deviceID}) async {
    if (photoSelectionResponse != null) {
      PhotoSelectionController photoSelectionController =
          PhotoSelectionController();
      FolderController folderController = FolderController();
      showLog("fillResponse  step 1  $photoSelectionResponse");
      if (photoSelectionResponse.photoSelectionData != null &&
          photoSelectionResponse.photoSelectionData?.code != null &&
          photoSelectionResponse.photoSelectionData?.code != '') {
        showLog("fillResponse  step 2");

        await photoSelectionController.fillPhotoSelection(
            photoSelectionResponse.photoSelectionData,
            eventCode,
            studioCode,
            photoSelectionResponse.photoSelectionData!.lastUpdatedAt!);
        await folderController.upsertFolders(
            photoSelectionResponse.photoSelectionData!.folders, eventCode,
            deviceID: deviceID);
      }
    }
  }

  Future<void> checkPhotoSelectionConfirmStatus(String eventCode) async {
    PhotoSelection? photoSelection =
        await photoSelectionDao.getPhotoSelectionWhereEventCode(eventCode);
    if (photoSelection != null) {
      if (photoSelection.confirmedStatus) {
        getListButton = true;
      } else {
        getListButton = false;
      }
    } else {
      getListButton = false;
    }
  }

  getEventName() async {

    Events? event =  eventModelDao.getEventWhereCode(eventCode);
    eventName = event!.name;
  }

  getcategoryName() async {

    Events? event = await eventModelDao.getEventWhereCode(eventCode);
    categoryName = event!.categoryName;
  }

  checkForSelectedImages() async {
    notifyListeners();
    isLoadingForGetSelectedImages = true;
    ImageController imageController = ImageController();
    List<SelectedImagesGettingModel>? images =
        await imageController.getSelectedImages(eventCode);
    //showLog('the selected image where ${images![1].photoSelectionImage}');
    showLog('checkForSelectedImages999 $images');

    for (SelectedImagesGettingModel data in images!) {
      showLog('checkForSelectedImages222${data.folder?.segregationPath}');

      showLog(
          "image ; ${data.photoSelectionImage?.name} Status : ${data.status?.status} origin : ${data.folder?.segregationPath} formate : ${data.folder?.segregationFormat}");

      showLog('checkForSelectedImages  segregationPath');
      if (data.folder?.segregationPath != null) {
        try {
          await getSelectedList();
          if (!context.mounted) return;
          showMessage(
              context,
              'Moved Successfully'
              '',
              false);
          showLog('_showNotification');
          if (Platform.isMacOS || Platform.isLinux) {
            await notificationUtils.showNotification();
          }
          isLoadingForGetSelectedImages = false;
          notifyListeners();
          return;
        } catch (e, s) {
          showLog('Something went Wrong1 $e ,$s');

          if (!context.mounted) return;
          showMessage(context, 'Something went wrong', true);
          isLoadingForGetSelectedImages = false;
          notifyListeners();
          return;
        }
      } else {
        showLog('elssseee');
        if (!context.mounted) return;
        isLoadingForGetSelectedImages = false;
        notifyListeners();
        showMessage(
            context,
            'Please select the original folder'
            '',
            true);

        /* await showDialog(
            context: context,
            builder: (context) {
              return CommonAlertDialog(
                title: "Pick folder",
                content:
                    'Choose the original folder to get the selected photos',
                actions: [
                  CommonElevatedButton(
                      text: 'Select Folder',
                      onTap: () async {
                        // assing new name
                        await pickFolder();

                        Navigator.pop(context);
                      }),
                  CommonElevatedButton(
                      text: 'cancel',
                      onTap: () {
                        Navigator.pop(context);
                      }),
                ],
              );
            });*/

        return;
      }
    }
  }

  pickFolder() async {
    String? result = (Platform.isWindows)
        ? file.getDirectory()?.path
        : await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await pickFolderPath(result);
    } else {
      // Do something else...
    }
    return;
  }

  void showMessage(BuildContext context, String message, bool? isErrorMessage,
      {SnackBarAction? action, int duration = 3}) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: isErrorMessage == true ? Colors.red : Colors.green,
        action: action,
        duration: Duration(seconds: duration),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    });
  }

  Future<void> pickFolderPath(String path) async {
    isLoading = true;
    setBusy(false);
    // path eg: /home/nithinbabu/Documents/picking

    showLog('folder path is $path');
    bool isDirectory = FileSystemEntity.isDirectorySync(path);

    showLog(isDirectory);
    if (isDirectory) {
      String lastFolderName = path;
      // String folderName = path.split("\ ").last;//path.split('.').last;
      showLog('foldername is $lastFolderName');
      TextEditingController nameController =
          TextEditingController(text: lastFolderName);
      await showDialog(
          context: context,
          builder: (context) {
            return CommonAlertDialog(
              title: "Add folder",
              contentWidget: Column(
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintMaxLines: 1,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 4.0))),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text('Please Select Image Format'),
                  const SizedBox(
                    height: 15,
                  ),
                  DropdownSearch<String>(
                    onChanged: (value) async {
                      if (value != null) {
                        showLog("the new formate $value");
                        isLoading = true;
                        customSegregationFormat = value;
                        isLoading = false;
                      }
                    },
                    selectedItem: customSegregationFormat,
                    items: extensionList,
                    //const ["jpeg", "pdf", "png"],
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Format",
                        hintText: "Select an format",
                        filled: true,
                      ),
                    ),
                    popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                        //  disabledItemFn: (int i) => i <= 3,
                        ),
                  ),
                ],
              ),
              actions: [
                CommonElevatedButton(
                    text: 'Add',
                    onTap: () async {
                      // assing new name
                      if (nameController.text.isNotEmpty) {
                        customSegregationPath = nameController.text;

                        Navigator.pop(context);
                      }
                    }),
                CommonElevatedButton(
                    text: 'cancel',
                    onTap: () {
                      Navigator.pop(context);
                      return;
                    }),
              ],
            );
          });
      if (customSegregationPath != null) {
        // Add folder API call
        await getSelectedListForOtherDevices();
      }
    } else {
      /// show toast that its not a directory
    }
    isLoading = false;
    setBusy(false);
  }

  getSelectedListForOtherDevices() async {
    showLog('getSelectedListForOtherDevices');
    //  var status = await Permission.storage.status;

    List<Folder>? folders =
        await folderModelDao.getFolderWhereEventCode(eventCode);

    if (folders != null && folders.isNotEmpty) {
      for (Folder folder in folders) {
        showLog("event length 2${folder.code}");
        showLog("event length 2${folder.segregationPath}");

        String? segregationPath = customSegregationPath;
        if (segregationPath != null) {
          showLog('deleting .. enter');

          if (Directory('$segregationPath/Selected/high').existsSync()) {
            showLog('deleting .. high');
            await Directory('$segregationPath/Selected/high')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected/medium').existsSync()) {
            showLog('deleting .. medium');

            await Directory('$segregationPath/Selected/medium')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected/low').existsSync()) {
            showLog('deleting .. low');

            await Directory('$segregationPath/Selected/low')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected').existsSync()) {
            showLog('deleting .. Selected');

            await Directory('$segregationPath/Selected')
                .delete(recursive: true);
          }
        } else {
          showLog("else");
        }
      }
    }

    ImageController imageController = ImageController();
    List<SelectedImagesGettingModel>? images =
        await imageController.getSelectedImages(eventCode);
    //showLog('the selected image where ${images![1].photoSelectionImage}');

    for (SelectedImagesGettingModel data in images!) {
      showLog(
          "image ; ${data.photoSelectionImage?.name} Status : ${data.status?.status} origin : ${data.folder?.segregationPath} formate : ${data.folder?.segregationFormat}");
      String? segregationPath = customSegregationPath;

      /* if (Directory('$segregationPath/Selected/').existsSync()) {
        await Directory('$segregationPath/Selected/').delete(recursive: true);
      }*/

      await fileUtil.createFolder('$segregationPath/Selected',
          data.folder?.code ?? "", '$segregationPath');
      await fileUtil.createFolder('$segregationPath/Selected/high',
          data.folder?.code ?? "", '$segregationPath');
      await fileUtil.createFolder('$segregationPath/Selected/medium',
          data.folder?.code ?? "", '$segregationPath');
      await fileUtil.createFolder('$segregationPath/Selected/low',
          data.folder?.code ?? "", '$segregationPath');
      await fileUtil.createFolder('$segregationPath/Selected/normal',
          data.folder?.code ?? "", '$segregationPath');

      try {
        await moveFile(
            folderCode: data.folder!.code!,
            name: data.photoSelectionImage!.name!,
            status: data.status!.status!,
            segregationPath: segregationPath!,
            segregationFormat: customSegregationFormat!,
            ratting: data.status!.rating!);
      } catch (e, s) {
        showLog('Something went Wrong $e ,$s');
        if (!context.mounted) return;

        showMessage(context, '$e' '', true);
        error = true;
        return;
      }
    }
    showMessage(
        context,
        'Moved Successfully'
        '',
        false);
    showLog('_showNotification');
    if (Platform.isMacOS || Platform.isLinux) {
      await notificationUtils.showNotification();
    }
    /* Directory directory = await getApplicationDocumentsDirectory();
    fileUtil.createFolder("ANEW");*/
  }

  getSelectedList() async {
    //  var status = await Permission.storage.status;
    List<Folder>? folders =
        await folderModelDao.getFolderWhereEventCode(eventCode);
    showLog("event length ${folders?.length}");
    if (folders != null && folders.isNotEmpty) {
      showLog("event length 2${folders.length}");

      for (Folder folder in folders) {
        showLog("event length 2${folder.code}");
        showLog("event length 2${folder.segregationPath}");

        String? segregationPath = folder.segregationPath;
        if (segregationPath != null) {
          showLog('deleting .. enter');

          if (Directory('$segregationPath/Selected/high').existsSync()) {
            showLog('deleting .. high');
            await Directory('$segregationPath/Selected/high')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected/medium').existsSync()) {
            showLog('deleting .. medium');

            await Directory('$segregationPath/Selected/medium')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected/low').existsSync()) {
            showLog('deleting .. low');

            await Directory('$segregationPath/Selected/low')
                .delete(recursive: true);
          }
          if (Directory('$segregationPath/Selected').existsSync()) {
            showLog('deleting .. Selected');

            await Directory('$segregationPath/Selected')
                .delete(recursive: true);
          }
        } else {
          showLog("else");
        }
      }
    }

    ImageController imageController = ImageController();
    List<SelectedImagesGettingModel>? images =
        await imageController.getSelectedImages(eventCode);
    //showLog('the selected image where ${images![1].photoSelectionImage}');
    missedImages.clear();

    for (SelectedImagesGettingModel data in images!) {
      String fileName =
          '${data.photoSelectionImage?.name?.split('.').first}.${data.folder?.segregationFormat}';
      String filePath = '${data.folder?.segregationPath}/$fileName';
      String? missedImage = fileUtil.getMissedImage(filePath, context);
      if (missedImage != null) {
        missedImages.add(missedImage);
      }
    }
    if (missedImages.isNotEmpty) {
      showLog('missedImages are $missedImages');
      final ScrollController _scrollController = ScrollController();

      showMessage(
          context,
          'Some images missed in your folder from PhotoSelected list'
          '',
          true,
          action: SnackBarAction(
            label: 'View Missed Images',
            backgroundColor: Colors.white,
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return CommonAlertDialog(
                      title: '${missedImages.length} missed Images',
                      contentWidget: SingleChildScrollView(
                        child: SizedBox(
                          height: 150,
                          width: 250,
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            interactive: true,
                            trackVisibility: true,
                            child: ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                itemCount: missedImages.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      CommonText(
                                        text:
                                            "${index + 1}.${missedImages[index]!}",
                                        isBody: true,
                                      ),
                                      const Divider()
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ),
                    );
                  });
            },
            textColor: Colors.red,
          ),
          duration: 28800);
    }

    for (SelectedImagesGettingModel data in images!) {
      showLog(
          "image ; ${data.photoSelectionImage?.name} Status : ${data.status?.status} origin : ${data.folder?.segregationPath} formate : ${data.folder?.segregationFormat}");
      String segregationPath = data.folder!.segregationPath!;

      /* if (Directory('$segregationPath/Selected/').existsSync()) {
        await Directory('$segregationPath/Selected/').delete(recursive: true);
      }*/

      await fileUtil.createFolder('$segregationPath/Selected',
          data.folder?.code ?? "", segregationPath);
      await fileUtil.createFolder('$segregationPath/Selected/high',
          data.folder?.code ?? "", segregationPath);
      await fileUtil.createFolder('$segregationPath/Selected/medium',
          data.folder?.code ?? "", segregationPath);
      await fileUtil.createFolder('$segregationPath/Selected/low',
          data.folder?.code ?? "", segregationPath);
      await fileUtil.createFolder('$segregationPath/Selected/normal',
          data.folder?.code ?? "", segregationPath);

      await moveFile(
          folderCode: data.folder!.code!,
          name: data.photoSelectionImage!.name!,
          status: data.status!.status!,
          segregationPath: data.folder!.segregationPath!,
          segregationFormat: data.folder!.segregationFormat!,
          ratting: data.status!.rating!);
    }
    /* Directory directory = await getApplicationDocumentsDirectory();
    fileUtil.createFolder("ANEW");*/
  }

/*  debugStatusAdd() async {
    List<String> codes = [
      'tlbtmxwk',
      'ubiwr0zl',
      'oedcoqc6',
      'frkhhmav',
    ];
    List<int> ratting = [
      1,
      1,
      2,
      3,
    ];

    List<appDb.PhotoSelectionImageStatusCompanion>
        photoSelectionImageStatusCompanion = [];
    for (int i = 0; i < ratting.length; i++) {
      photoSelectionImageStatusCompanion.add(
          appDb.PhotoSelectionImageStatusCompanion(
              code: drift.Value(codes[i]),
              status: const drift.Value(1),
              rating: drift.Value(ratting[i])));
    }
    PhotoSelectionImageStatusDao photoSelectionImageDao =
        PhotoSelectionImageStatusDao();
    await photoSelectionImageDao
        .insertAllImages(photoSelectionImageStatusCompanion);
  }*/

  moveFile(
      {required String folderCode,
      required String name,
      required int status,
      required String segregationPath,
      required String segregationFormat,
      required int ratting}) async {
    String fileName = '${name.split('.').first}.$segregationFormat';
    String filePath = '$segregationPath/$fileName';
    Uint8List? uint8list = fileUtil.getImage(filePath, context);
    Folder? rootFolder =
        await folderModelDao.getFolderWhereCode(folderCode);
    if (rootFolder != null &&
        rootFolder.customSegregationPath != segregationPath) {
      showLog(
          'segregationPath in move file fn ${rootFolder.customSegregationPath ?? "NULL"}');
      if (rootFolder.customSegregationPath != null) {
        segregationPath =
            '${rootFolder.customSegregationPath!}/${rootFolder.name}';
      }
    }
    if (uint8list != null) {
      if (ratting == 1) {
        showLog("low>> $fileName");
        fileUtil.writeTheimage(
            '$segregationPath/Selected/low/$fileName', uint8list);
      }
      if (ratting == 2) {
        showLog("medium>> $fileName");
        fileUtil.writeTheimage(
            '$segregationPath/Selected/medium/$fileName', uint8list);
      }
      if (ratting == 3) {
        showLog("high>> $fileName");

        fileUtil.writeTheimage(
            '$segregationPath/Selected/high/$fileName', uint8list);
      }
      if (ratting == 0) {
        showLog("normal>> $fileName");
        fileUtil.writeTheimage(
            '$segregationPath/Selected/normal/$fileName', uint8list);
      }
    }
  }
}
