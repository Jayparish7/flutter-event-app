import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as drift;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as pathq;
import 'package:photomall_studio_manager/api/apiResponseModels/folder_store_response.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/image_upload.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/alert_dialog.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/eAlbumDetail/eventdetail_arguments_model.dart';
import 'package:photomall_studio_manager/utils/file_utils.dart';
import 'package:photomall_studio_manager/utils/image_util.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../api/apiRequestModels/digital_oceans_space_service.dart';
import '../../api/apiResponseModels/google_drive_files_api_response_model.dart'
    as drive_file;

import '../../common_widgets/common_appbar.dart';
import '../../common_widgets/common_text.dart';
import '../../controllers/image_controller.dart';
import '../../database/dao/photo_selection_dao.dart';
import '../../database/dao/upload_status_dao.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../internet/internet_provider.dart';
import '../../main.dart';
import '../../utils/device_util.dart';
import '../../utils/google_drive_utils.dart';
import '../../utils/notification_utils.dart';
import '../eventSubView/event_sub_view_arguments.dart';

class EventDetailedController extends BaseObserver {
  EventDetailArguments eventDetailedArguments =
      EventDetailArguments(studioCode: "");
  final ValueNotifier<List<Folder>> folderList =
      ValueNotifier<List<Folder>>([]);
  final ValueNotifier<List<PhotoSelectionImage>>
      valueNotifierPhotoSelectionImages =
      ValueNotifier<List<PhotoSelectionImage>>([]);
  final ValueNotifier<List<PhotoSelectionImage>>
      localValueNotifierPhotoSelectionImages =
      ValueNotifier<List<PhotoSelectionImage>>([]);
  final StreamController<ImageUploadProgress> _progressController =
      StreamController<ImageUploadProgress>();
  bool isLoadingForGetSelectedImages = false;
  NotificationUtils notificationUtils = NotificationUtils();
  List<PhotoSelectionImage> images = [];
  List<String?> missedImages = [];
  DeviceUtil deviceUtil = DeviceUtil();
  GoogleDriveUtils googleDriveUtils = GoogleDriveUtils();

  Stream<ImageUploadProgress> get uploadProgressStream =>
      _progressController.stream;
  bool isLoading = false;
  bool isFolderListeningStoped = false;
  bool isParentFolder = false;
  bool isAlertDialog = false;
  String? routePath;
  final imageModelDao = objectBox.imageModelDao;

  final folderModelDao = objectBox.folderModelDao;

  final eventModelDao = objectBox.eventModelDao;

  final photoSelectionDao = objectBox.photoSelectionDao;

  final uploadStatusDao = objectBox.uploadStatusDao;

  List<PhotoSelectionImage>? uploadedImages = [];
  List<UploadState> uploadStatusEntity = [];
  int imageCount = 0;
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;
  String eventCode = '';
  String eventName = '';
  String studioCode = '';
  String folderCode = '';
  String folderName = '';
  String folderSegritionPath = '';
  String folderCustomSegritionPath = '';
  String folderSegritionFormat = '';
  String? deviceId = '';
  List<String> extensionList = [];
  FileUtil fileUtil = FileUtil();
  ScrollController scrollController = ScrollController();
  String? customSegregationFormat;
  String? customSegregationPath;
  String customFolderName = '';
  String? imageName = '';
  double? progress;
  bool listenOff = false;
  final ValueNotifier<String> uIImageName = ValueNotifier<String>('');
  final ValueNotifier<String> uIProgress = ValueNotifier<String>('');
  final ProgressController controller;
  bool pSConfirmStatus = false;
  List<String> imagesList = [];
  Folder? folder;
  List< PhotoSelectionImage>? pendingImagesForUpload;
  var uploadState = true.obs;
  String? pmFilePath;
  EventDetailArguments arguments;
  Events? res;

  EventDetailedController({
    required this.context,
    this.apiHandler,
    required this.controller,
    required this.arguments,
  }) {
    apiRepo = Api(context);
  }

  Future<void> getInitialValues(EventDetailArguments arguments) async {
    try {
      arguments = arguments;
      isLoading = true;
      setBusy(false);
      await FileUploadCredentials.setUploadCredentialsToPreference();

      pmFilePath = await PreferenceHelper.getString(originalFilePathKey);
      showLog("Initial method called${controller.progress}");
      deviceId = await PreferenceHelper.getString(deviceIdPreferenceKey);
      showLog("Initial method called${controller.progress}");

      folderList.value.clear();
      valueNotifierPhotoSelectionImages.value.clear();
      eventDetailedArguments = arguments;

      if (arguments.folderCode != null) {
        folderCode = arguments.folderCode!;
        studioCode = arguments.studioCode;
        Folder? rootFolder =
            await folderModelDao.getFolderWhereCode(folderCode);
        folderName = rootFolder!.name;
        eventCode = rootFolder.eventCode;
        //eventName = rootFolder.name;
        routePath = rootFolder.path;
        folderSegritionPath = rootFolder.segregationPath ?? "";
        folderCustomSegritionPath = rootFolder.customSegregationPath ?? "";
        folderSegritionFormat = rootFolder.segregationFormat ?? "";
        await checkPhotoSelectionConfirmStatus(eventCode);
        if (listenOff != true) {
          folderTableListen(arguments.folderCode!);
          await getImagesTable(arguments.folderCode!);
          //imagesTableListen(arguments.folderCode!);
          showLog('eventname${arguments.eventName!}');
          listenLocalDirectory(folderCode: arguments.folderCode!);
        }
      } else {
        isParentFolder = true;
        studioCode = eventDetailedArguments.studioCode;
        eventCode = arguments.eventCode!;
        eventName = arguments.eventName!;

        Folder? folder = await folderModelDao
            .getFoldersByEventAndParentNull(arguments.eventCode!);
        if (folder != null) {
          folderName = folder.name;
          folderCode = folder.code;
          folderList.value.add(folder);
        }
        await checkPhotoSelectionConfirmStatus(eventCode);
      }
      isLoading = false;
      setBusy(false);
    } catch (e, s) {
      showLog("the error i got where $e ---$s");
    }

    showLog('getAlertDialogValues1');
    await getAlertDialogValues();
    showLog(
        'getAlertDialogValues2 ${valueNotifierPhotoSelectionImages.value.length}');
    await getExtensionList();
    uploadedImages = await imageModelDao.getUploadedImages(folderCode);
    showLog('valueNotifierPhotoSelectionImages count get is ${valueNotifierPhotoSelectionImages.value.length}');
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

  checkForSelectedImages() async {
    notifyListeners();
    isLoadingForGetSelectedImages = true;
    ImageController imageController = ImageController();
    List<SelectedImagesGettingModel>? images =
        await imageController.getSelectedImagesForFolder(eventCode, folderCode);
    //showLog('the selected image where ${images![1].photoSelectionImage}');
    showLog('No Images Selected in this Folder$images');

    if (images!.isEmpty) {
      showLog('No Images Selected in this Folder');
      isLoadingForGetSelectedImages = false;
      notifyListeners();

      showMessage(
          context,
          'No Images Selected in this Folder'
          '',
          true);
      return;
    }
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
          showMessage(
              context,
              'The specified images path might be incorrect. Please verify the path and try again.',
              true);
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
        return;
      }
    }
  }

  getSelectedList() async {
    //  var status = await Permission.storage.status;
    List<Folder>? folders =
        await folderModelDao.getFolderWhereFolderCode(folderCode);
    showLog("getSelectedList individual length ${folders?.length}");
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
        await imageController.getSelectedImagesForFolder(eventCode, folderCode);
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
  }

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

  Future<void> checkPhotoSelectionConfirmStatus(String eventCode) async {
    PhotoSelection? photoSelection =
        await photoSelectionDao.getPhotoSelectionWhereEventCode(eventCode);
    showLog(
        'checkPhotoSelectionConfirmStatus ${photoSelection?.confirmedStatus}');
    if (photoSelection != null) {
      if (photoSelection.confirmedStatus) {
        pSConfirmStatus = true;
      } else {
        pSConfirmStatus = false;
      }
    } else {
      pSConfirmStatus = false;
    }
  }

  Stream<String> streamProgress() async* {
    Stream<List<PhotoSelectionImage>> streamPhotoSelectionImages =
        imageModelDao.streamImageNamesWhereUploadedAndFolderCode(folderCode);

    await for (List<PhotoSelectionImage> progress
        in streamPhotoSelectionImages) {
      int length = progress.length;

      for (PhotoSelectionImage image in progress) {
        // Emit progress information as a String
        yield (length != valueNotifierPhotoSelectionImages.value.length)
            ? 'Uploading: ${image.name},\n$length of ${valueNotifierPhotoSelectionImages.value.length} files processed'
            : 'Uploaded Successfully';
      }
    }
  }

  void addPhotosToList() {
    int previousLength = localValueNotifierPhotoSelectionImages.value.length;
    int counter = 0;
    if (valueNotifierPhotoSelectionImages.value != null) {
      for (PhotoSelectionImage? photos
          in valueNotifierPhotoSelectionImages.value!) {
        if (counter == 5) {
          break;
        }
        if (!localValueNotifierPhotoSelectionImages.value.contains(photos)) {
          showLog("add images $counter");
          localValueNotifierPhotoSelectionImages.value.add(photos!);
          counter++;
        }
      }
      if (previousLength <
          localValueNotifierPhotoSelectionImages.value.length) {
        showLog("more image added..");
        setBusy(false);
      }
    }
  }

  List<FileSystemEntity> getFiles(String path) {
    return Directory("$path/").listSync();
  }

  getExtensionList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    extensionList = prefs.getStringList(downloadExtensionKey) ?? [];

    showLog('valuess are $extensionList');
  }

  onFolderSelected(
    String folderId,
    String folderName,
  ) async {
    final googleClient = GoogleHttpClient(driveAccessToken);
    showLog("onFolderSelected $folderId $folderName $driveAccessToken");
    drive_file.GoogleDriveFilesApiResponseModel driveFiles =
        await googleDriveUtils.getFilesInFolder(
            folderId: folderId, client: googleClient);
    showLog(
        "onFolderSelected - getFilesInFolder ${driveFiles.files!.first.name}");
    await pickFolder(folderName,
        isFromGoogleDrive: true, files: driveFiles.files);
    Navigator.pop(context);
  }

  Future<void> pickFolder(String path,
      {bool isFromGoogleDrive = false,
      List<drive_file.FileElement>? files}) async {
    isLoading = true;
    setBusy(false);
    showLog("pickFolder $isFromGoogleDrive $files");
    showLog('folder path is $path');
    bool isDirectory = isFromGoogleDrive == true
        ? true
        : FileSystemEntity.isDirectorySync(path);

    showLog(isDirectory);
    if (isDirectory) {
      String lastFolderName = pathq.basename(path);
      // String folderName = path.split("\ ").last;//path.split('.').last;
      showLog('folderName is $lastFolderName');
      TextEditingController nameController =
          TextEditingController(text: lastFolderName);
      await showDialog(
          context: context,
          builder: (context) {
            return CommonAlertDialog(
              title: "Add folder",
              contentWidget: TextField(
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
              actions: [
                CustomPrimaryButton(
                    text: 'Add',
                    onPressed: () {
                      // assing new name
                      if (nameController.text.isNotEmpty) {
                        folderName = nameController.text;
                        Navigator.pop(context);
                      }
                    }),
                CustomPrimaryButton(
                    text: 'cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            );
          });
      FolderCreate? folderCreate;
      if (folderName != '') {
        // Add folder API call
        folderCreate = await createFolderApiCall(folderName, path: path);
      } else {
        showLog("folderName is empty");
      }
      if (folderCreate != null && folderCreate.status) {
        await insertImagesInThisPath(path, folderCreate.folderCode!, arguments!,
            isFromGoogleDrive: isFromGoogleDrive, driveFiles: files);
      } else {
        // show toast folder cant be created
      }
    } else {
      /// show toast that its not a directory
    }
    isLoading = false;
    setBusy(false);
  }

  pickFolderCode(String? folderName) async {
    String? result = (Platform.isWindows)
        ? file.getDirectory()?.path
        : await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      showLog('pickFolderCode pickFolderWinRT $result');
      await pickFolderPath(result, folderName);
      return;
    } else {
      // Do something else...
    }
    return;
  }

  Future<void> pickFolderPath(String path, String? folderName) async {
    isLoading = true;
    //setBusy(false);
    // path eg: /home/nithinbabu/Documents/picking

    showLog('folder path is $path');
    bool isDirectory = FileSystemEntity.isDirectorySync(path);

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
                      customFolderName = folderName!;

                      showLog(
                          'res path 0 is $customSegregationPath,format is $customSegregationFormat}');
                      // assing new name
                      if (nameController.text.isNotEmpty) {
                        customSegregationPath = nameController.text;
                        await folderModelDao
                            .updateCustomSegregationPathByFolderName(
                                folderName: customFolderName,
                                path: customSegregationPath!);
                        await folderModelDao
                            .updateSegregationFormatByFolderName(
                                folderName: customFolderName,
                                format: customSegregationFormat!);
                        await folderModelDao.updateSegregationPathByFolderName(
                            folderName: customFolderName,
                            path: customSegregationPath!);
                        listenOff = true;
                        showLog(
                            'res $listenOff path is $customSegregationPath,format is $customSegregationFormat name is $customFolderName');
                        Navigator.pop(context);
                        return;
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
    } else {
      /// show toast that its not a directory
    }
    isLoading = false;
    //setBusy(false);
  }

  /// PICK IMAGES ..
/*  Future<void> pickImages(FilePickerResult result) async {
    ImageModelDao imageModelDao = ImageModelDao();
    for (PlatformFile platformFile in result.files) {
      showLog(' path : ${platformFile.path}');
      await imageModelDao.insertImages(
          imagesCompanion: appDb.ImagesCompanion(
              folderCode: drift.Value(folderCode),
              path: drift.Value(platformFile.path!),
              name: drift.Value(platformFile.path!.split('/').last),
              code: drift.Value(null),
              lastUpdatedAt: drift.Value(0),
              compressed: drift.Value(false),
              uploaded: drift.Value(false) // api
              ));
    }
    uploadImagesInThisFolder(folderCode);
  }*/
  Future<List<FileSystemEntity>> checkSubFolderAndCreateFolder(
      List<FileSystemEntity> files,
      {String? parentFolderCode}) async {
    List<FileSystemEntity> filteredFiles = [];

    for (FileSystemEntity file in files) {
      if (file is Directory) {
        // If it's a directory, print a log and skip it
        folderName = pathq.basename(file.path);
        FolderCreate folderCreate = await createFolderApiCall(
          folderName, path: file.path,
          parentCode: parentFolderCode, // Track parent-child relationship
        );

        if (folderCreate.status) {
          await insertImagesInThisPath(
              file.path, folderCreate.folderCode!, arguments!,
              isFromSubFolder: true);
        }
        showLog("checkSubFolderAndCreateFolder Directory: $file");
      } else {
        filteredFiles.add(file);
        showLog("checkSubFolderAndCreateFolder file: $file");

        // If it's a file, add it to the filtered list
      }
    }
    return filteredFiles;
  }

  /// PICK IMAGES ..

  Future<void> insertImagesInThisPath(
      String path, String folderCode, EventDetailArguments arguments,
      {bool isFromSubFolder = false,
      bool isFromGoogleDrive = false,
      List<drive_file.FileElement>? driveFiles}) async {
    showLog("step 1");
    List<FileSystemEntity> files = [];
    if (isFromGoogleDrive == false) {
      String directory = path;
      files = Directory("$directory/").listSync(recursive: false);
      files = await checkSubFolderAndCreateFolder(files,
          parentFolderCode: folderCode);
      showLog("step 2");
    }

    if (files.isNotEmpty ||
        (isFromGoogleDrive == true && driveFiles!.isNotEmpty)) {
      showLog("step 3");
      if (!context.mounted) return;
      {
        Navigator.pushNamed(context, RoutePaths.eventDetailed,
                arguments: EventDetailArguments(
                    studioCode: studioCode,
                    isSubFolder: true,
                    eventCode: eventCode,
                    eventName: eventName,
                    folderCode: folderCode))
            .then((val) async {
          showLog('RoutePaths.eventDetailed new folder');
          getInitialValues(arguments);
          notifyListeners();
          if (val == true) {
            // This function will be called if 'PageTwo' returns true.
            showLog('unique returned back');
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              RoutePaths.eventSubView,
              arguments: EventSubViewArguments(
                  eventCode: eventCode,
                  studioCode: studioCode,
                  eventName: eventName),
            );
          }
        });
      }
      await insertAllImages(files, folderCode,
          driveFiles: driveFiles, isFromGoogleDrive: isFromGoogleDrive);
    }
  }

  Future<void> insertAllImages(List<FileSystemEntity> files, String folderCode,
      {bool isFromGoogleDrive = false,
      List<drive_file.FileElement>? driveFiles}) async {

    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: pmFilePath ?? "photomall");
    List<PhotoSelectionImage> imagesCompanion = [];
    Set<String> processedPaths = {};
    int batchSize = 10000;
    imageCount = files.length;
    /* for (int i = 0; i < imageCount; i += batchSize) {
      List<FileSystemEntity> batch = files.sublist(
          i, i + batchSize < imageCount ? i + batchSize : imageCount);*/
    if (files.isNotEmpty) {
      for (FileSystemEntity file in files) {
        String? extension = getExtension(file);
        bool isDirectory = FileSystemEntity.isDirectorySync(file.path);
        showLog("step 4    $extension  $isDirectory");

        if (!processedPaths.contains(file.path)) {
          if ((extension == 'jpeg' || extension == 'jpg') && !isDirectory) {
            imagesCompanion.add(PhotoSelectionImage(
              folderCode:  folderCode,
              eventCode: eventCode,
              path: file.path,
              name: file.path.split('/').last,
              code: null,
              sha256: service.generateUniqueId(),
              lastUpdatedAt: 0,
              uploaded: false, // api
            ));
            processedPaths.add(file.path);
            showLog("processedPaths : $processedPaths");
            showLog(
                "name : ${file.path.split('/').last.replaceAll("jpeg", "").replaceAll("jpg", "").replaceAll(".", "")}");
            showLog("name :: ${file.path.split('/').last}");
          }
        } else {
          // Handle duplicate path (optional)
          showLog("Duplicate file path found: ${file.path}");
        }
      }
    }
    if (driveFiles != null && driveFiles.isNotEmpty) {
      showLog("driveFiles extension is ${driveFiles.first.mimeType}");

      for (drive_file.FileElement file in driveFiles) {
        String? extension = file.mimeType?.split("/").last.toString();
        showLog("drive_file extension ${file.mimeType}");
        if (!processedPaths.contains(file.name)) {
          if ((extension == 'jpeg' || extension == 'jpg')) {
            imagesCompanion.add(PhotoSelectionImage(
              folderCode: folderCode,
              eventCode: eventCode,
              path: "googleDriveFile",
              name: file.name,
              code: null,
              sha256: file.id,
              lastUpdatedAt: 0,
              uploaded: false, // api
            ));
            processedPaths.add(file.name ?? '');
            showLog("processedPaths : $processedPaths");
          }
        } else {
          // Handle duplicate path (optional)
          showLog("Duplicate file path found: ${file.name}");
        }
      }
    }
    if (imagesCompanion.isNotEmpty) {
      await imageModelDao.insertAllImages( imagesCompanion);
    }
    //}
    await folderModelDao.updateFilesCount(
        folderCode: folderCode,
        count:
            isFromGoogleDrive == true ? driveFiles?.length ?? 0 : files.length);
    setBusy(false);

    // uploadImagesInThisFolder(folderCode);

    setBusy(false);

    isFolderListeningStoped = true;

    showLog("navigate returned..");
    isFolderListeningStoped = false;
    listenLocalDirectory(folderCode: folderCode);
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Future<Uint8List?> compressTheFile(FileSystemEntity file) async {
    // screen_display = 3
    //  img_width = 2560;
    //  img_height = 1440;
    int? screenDisplay = 3;
    double convertedHeight = 0;
    double convertedWidth = 0;
    res = await eventModelDao.getEventWhereCode(eventCode);
    if (res != null) {
      screenDisplay = 2;
    }
    ImageSize studioSize = ImageSize(
      height: 1080,
      width: 1920,
    );
    Uint8List bytes = File(file.path).readAsBytesSync();
    String name = file.path.split('/').last;
    ImageSize? imagesize = ImageUtil.getHeightOfFirstImage(bytes);

    if (imagesize != null) {
      if (imagesize.height! > imagesize.width!) {
        // is portrait
        if (imagesize.height! > studioSize.height!) {
          convertedHeight = studioSize.height!.toDouble();
          double deductionOfHeight = imagesize.height! / studioSize.height!;
          convertedWidth = double.parse(
              (imagesize.width! / deductionOfHeight).round().toString());
        }
      } else {
        // is landscape
        if (imagesize.width! > studioSize.width!) {
          convertedWidth = studioSize.width!.toDouble();
          double deductionOfWidth = imagesize.width! / studioSize.width!;
          convertedHeight =
              double.parse("${imagesize.height! / deductionOfWidth}");
        }
      }
      if (convertedHeight != 0 && convertedWidth != 0) {
        showLog('resizeImageIso init');
        ImageUtil imageUtil = ImageUtil();
        Uint8List?
            byte = /*await imageUtil.compressImageForDesktop(
            file.path, convertedWidth.toInt(), convertedHeight.toInt());*/
            await compute(imageUtil.compressImageForDesktopInIsolate, {
          'path': file.path,
          'targetedHeight': convertedHeight.toInt(),
          'targetedWidth': convertedWidth.toInt(),
        });
        showLog('resizeImageIso init ${byte?.length}');

        if (byte != null) {
          bytes = byte;
        }
      }
      return bytes;
    }
    return null;
  }

  createFolder() async {
    String folderName = '';
    TextEditingController nameController =
        TextEditingController(text: 'new Folder');
    if (context.mounted) {
      await showDialog(
          context: context,
          builder: (context) {
            return CommonAlertDialog(
              title: "Add folder",
              contentWidget: TextField(
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
              actions: [
                CommonElevatedButton(
                    text: 'Add',
                    onTap: () {
                      // assing new name
                      if (nameController.text.isNotEmpty) {
                        folderName = nameController.text;
                      }
                      Navigator.pop(context);
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
    }
    if (folderName.isNotEmpty) {
      FolderCreate folderCreate = await createFolderApiCall(folderName);
    }

    setBusy(false);
  }

  Future<FolderCreate> createFolderApiCall(String folderName,
      {String? path, String? parentCode}) async {
    try {


      // Call API to create the folder
      FolderStore? folderStore = await apiRepo!.folderStoreApiCall(
        eventCode: eventCode,
        studioCode: studioCode,
        parentCode: parentCode ?? folderCode,
        // Use passed parentCode or root folderCode
        folderName: folderName,
        path: path,
      );

      if (folderStore?.data != null) {
        // Insert the folder into the database
        await folderModelDao.insertFolder(Folder(
            code:folderStore!.data!.code!,
            name: folderStore.data!.name!,
            eventCode: eventCode,
            parentCode: parentCode ?? folderCode,
            uploadStatus: 1,
            // Maintain hierarchy
            path:path,
            lastUpdatedAt:folderStore.data!.lastUpdatedAt ?? 0,
            sync: true,
            deviceId: deviceId,
            filesCount: 0,
            segregationFormat: "jpeg",
            segregationPath: path));
        return FolderCreate(status: true, folderCode: folderStore.data!.code!);
      }
    } catch (e, stackTrace) {
      showLog("Error creating folder: $e\nStackTrace: $stackTrace");
      await ToastUtil.showSnackBarAtCurrentState(
          'The folder name has already been taken.',
          seconds: 2);
    }

    return FolderCreate(status: false, folderCode: null);
  }

  /*Future<FolderCreate> createFolderApiCall(String folderName,
      {String? path}) async {
    try {
      FolderModelDao folderModelDao = FolderModelDao();
      FolderStore? folderStore = await apiRepo!.folderStoreApiCall(
        eventCode: eventCode,
        studioCode: studioCode,
        parentCode: folderCode,
        folderName: folderName,
        path: path,
      );
      if (folderStore != null) {
        // insert folder and images
        await folderModelDao.insertFolder(appDb.FoldersCompanion(
            code: drift.Value(folderStore.data!.code!),
            name: drift.Value(folderStore.data!.name!),
            lastUpdatedAt: drift.Value(folderStore.data!.lastUpdatedAt!),
            eventCode: drift.Value(eventCode),
            path: drift.Value(path),
            parentCode: drift.Value(folderStore.data!.parentCode!),
            sync: const drift.Value(true),
            deviceId: drift.Value(deviceId),
            filesCount: const drift.Value(0),
            segregationFormat: const drift.Value("jpeg"),
            segregationPath: drift.Value(path)));
        return FolderCreate(status: true, folderCode: folderStore.data!.code!);
      } else {
        return FolderCreate(status: false, folderCode: null);
      }
    } catch (e) {
      showLog("Error : creating folder issue $e");
      return FolderCreate(status: false, folderCode: null);
    }
  }
*/
  Future<ImageUploadResponse?> uploadImageApiCall({
    required String folderCode,
    required String image,
    required String studioCode,
    required String path,
    required String fileName,
    required String filePath,
    required String imageHash,
    required String preSignedUrlCode,
    required String imageHeight,
    required String extension,
    required String imageWidth,
    required String screenDisplay,
  }) async {
    ImageUploadResponse? imageUploadResponse;
    try {
      imageUploadResponse = await apiRepo!.imageUploadApiCall(
        type: 'folders',
        studioCode: studioCode,
        ableCode: folderCode,
        jvtFileName: image,
        fileName: fileName,
        filePath: filePath,
        imageHash: imageHash,
        preSignedUrlCode: preSignedUrlCode,
        imageHeight: imageHeight,
        extension: extension,
        eventCode: eventCode,
        imageWidth: imageWidth,
        screenDisplay: screenDisplay,
      );

      return imageUploadResponse;
    } catch (e, s) {
      showLog(
          'exception in api uploadImageApiCall $imageUploadResponse $e $s ');
      return null;
    }
  }

  Future<ImageUploadResponse?> multipleUploadImageApiCall(
      {required String folderCode,
      required List<String> image,
      required String studioCode,
      required String path,
      required List<String> fileName}) async {
    ImageUploadResponse? imageUploadResponse =
        await apiRepo!.multipleImageUploadApiCall(
      type: 'folders',
      studioCode: studioCode,
      ableCode: folderCode,
      images: image,
      fileNames: fileName,
    );
    return imageUploadResponse;
  }

  Future<String> generateImageHash(File imageFile) async {
    // Read the image file into memory
    List<int> bytes = await imageFile.readAsBytes();

    // Calculate hash
    Digest digest = sha256.convert(bytes);

    // Convert hash bytes to string
    return digest.toString();
  }

/*  Future<void> uploadImagesInThisFolder(String folderCode) async {
    try {
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate)
          : null;

      showLog('uploadImagesInThisFolder uploadStatus ${folder?.uploadStatus} ');
      ImageModelDao imageModelDao = ImageModelDao();
      // Fetch all images that are not uploaded initially

      List<appDb.PhotoSelectionImage>? images =
      await imageModelDao.getImagesNotuploaded(folderCode);
      if (images!.isEmpty) {
        controller.stopProcessing();
        await uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: folderName, uploadingName: '', remainingFileCount: 0);
      }
      // Process images in batches of size batchSize
      int batchSize =
      50; // You can adjust the batch size based on your requirements
      List<Future<void>> uploadFutures = [];

      // Total number of images to upload in this batch
      int totalImagesInBatch = images!.length;
      int uploadedImages = 0;
      int totalUploadedBytes = 0;
      DateTime startTime = DateTime.now();
      // Process images in batches
      for (int i = 0; i < images.length; i += batchSize) {
        folder = await folderModelDao.getFolderWhereCode(folderCode);
        if (folder?.uploadStatus != null && folder?.uploadStatus != 1) {
          showLog('uploadStopped ${folder?.uploadStatus} ');
          uploadState.value = false;
          return;
        }
        List<FileSystemEntity> files =
        Directory("${images[i].path?.replaceAll("${images[i].name}", '')}/")
            .listSync();
        appDb.UploadStateData? uploadStatus = await uploadStatusDao
            .getUploadStateWhereAlbumName(albumName: folderName);
        if (uploadStatus == null) {
          var event = await eventModelDao.getEventWhereCode(eventCode);

          uploadStatusEntity.add(appDb.UploadStateCompanion(
              eventName: drift.Value(event?.name),
              albumName: drift.Value(folderName),
              remainingFilesCount: drift.Value(images.length),
              totalFilesCount: drift.Value(files.length),
              uploadComplete: const drift.Value(false)));
          await uploadStatusDao.insertUploadStatus(uploadStatusEntity);
        }

        List<appDb.PhotoSelectionImage> batchImages = images.sublist(
            i, i + batchSize < images.length ? i + batchSize : images.length);
        uploadedImages += batchImages.length;

        // Process each image in the batch concurrently
        for (appDb.PhotoSelectionImage image in batchImages) {
          uploadFutures.add(_processImage(image, folderCode, uploadedImages));
          imageName = image.name;
          List<appDb.PhotoSelectionImage>? remainingFileCount =
          await imageModelDao.getImagesNotuploaded(folderCode);
          await uploadStatusDao.updateUploadStateWhereAlbumName(
              albumName: folderName,
              uploadingName: imageName ?? '',
              remainingFileCount: remainingFileCount!.length);
          showLog('updateUploadStateWhereAlbumName $uploadStatus');
          controller.startProcessing();
          controller.progress.value = image.name!;
          showLog('getUploadedImages ${controller.progress.value}');
        }
        showLog('Wait for all images in the batch to be processed j');
        // Wait for all images in the batch to be processed
        await Future.wait(uploadFutures);
        // Update progress after processing the batch
        // uploadedImages += batchImages.length;
        //progress = uploadedImages / totalImagesInBatch;
        // showLog('Progress: $progress');
        showLog(
            'uploadFutures event detailed controller 1 before length is  ${uploadFutures.length}');
        uploadFutures.clear();
        showLog(
            'uploadFutures event detailed controller 1  after length is  ${uploadFutures.length}');
        // Update progress
      }
      showLog(
          'uploadFutures event detailed controller before length is  ${uploadFutures.length}');
      appDb.UploadStateData? uploadStatus = await uploadStatusDao
          .getUploadStateWhereAlbumName(albumName: folderName);
      if (uploadStatus != null) {
        await uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: folderName, uploadingName: '', remainingFileCount: 0);
      }
      uploadFutures.clear();
      showLog(
          'uploadFutures event detailed controller after length is  ${uploadFutures.length}');
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
    } catch (e, s) {
      showLog('exception in uploadImagesInThisFolder $e & $s');
    } // Fetch the next batch of images
  }

  Future<void> _processImage(appDb.PhotoSelectionImage image, String folderCode,
      int uploadedImages) async {
    String path = image.path ?? '$routePath/${image.name}';
    Uint8List? uInt8list;
    showLog("Going to compress: $path");
    try {
      uInt8list = await compressTheFile(File(path));
    } catch (e, s) {
      uInt8list =await ImageUtil.compressImageToUint8List(path);
      showLog('Error in compressing the image:  .... ');
      //return;
    }

    if (uInt8list != null) {
      String? extension = lookupMimeType(path);
      if (extension != null) {
        extension = extension.split('/').last;
      }

      /// Calculate the size of the data to be uploaded
      int imageSizeBytes = uInt8list.length;
      DateTime uploadStartTime = DateTime.now();
      DigitalOceanSpacesService service = DigitalOceanSpacesService(
          accessKey: credentials!.pmAccessKeyId!,
          bucketName: credentials!.pmBucket!,
          endpoint: credentials!.pmUrl!,
          region: credentials!.pmDefaultRegion!,
          secretKey: credentials!.pmSecretAccessKey!,
          uploadFolderName: credentials!.pmFilePath!);
      String uniqueImageName = service.generateUniqueId();

      /// Upload the image
      String? uploadImageHash =
      await service.uploadFile(uInt8list, uniqueImageName, extension!);
      final imageUrl = await service.getFileUrl(uniqueImageName);
      showLog('Image URL: $imageUrl');
      ImageUploadResponse? imageUploadResponse;
      if (uploadImageHash != null && uploadImageHash != '') {
        imageUploadResponse = await uploadImageApiCall(
            path: image.path!,
            folderCode: folderCode,
            image: uniqueImageName,
            studioCode: studioCode,
            fileName: pathq.basename(path),
            filePath: credentials!.pmFilePath!,
            imageHash: uploadImageHash,
            size: "${imageSizeBytes / 1024}");
        showLog('uploadImageHash folders $uploadImageHash');
      }

      /// Calculate the upload speed
      int uploadTimeSeconds =
          DateTime.now().difference(uploadStartTime).inSeconds;

      /// Ensure at least 1 second elapsed time to avoid division by zero
      uploadTimeSeconds = uploadTimeSeconds > 0 ? uploadTimeSeconds : 1;

      double uploadSpeed = (imageSizeBytes / 1024) / uploadTimeSeconds; // KB/s
      controller.uploadSpeed.value = uploadSpeed;
      showLog('Upload speed: ${uploadSpeed.toStringAsFixed(2)} KB/s');

      if (imageUploadResponse != null && imageUploadResponse.file!=null) {
        // Update image uploaded status in the database
        await imageModelDao.updateImageUploadedStatusTrue(
            image.id, imageUploadResponse.file!.code!, path, '');
      } else {
        await InterNetProvider.waitForInternet();
        showLog('ImageUploadResponse is null,so restart upload');
        Platform.isWindows
            ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
            : null;

        await Future.delayed(const Duration(seconds: 5));
        uploadImagesInThisFolder(folderCode);
      }
    }
  }*/
  Future<void> uploadImagesInThisFolder(String folderCode) async {
    try {
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate)
          : null;

      showLog('uploadImagesInThisFolder uploadStatus ${folder?.uploadStatus} ');


      // Fetch all images that are not uploaded initially
      images = await imageModelDao.getImagesNotuploaded(folderCode) ?? [];
      List<PhotoSelectionImage>? totalFiles =
          await imageModelDao.getImagesWhereFolderCode(folderCode);
      if (images.isEmpty) {
        controller.stopProcessing();
          uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: folderName, uploadingName: '', remainingFileCount: 0);
        return;
      }

      // Process images in batches of size batchSize
      int batchSize = await deviceUtil
          .calculateBatchSize(); // Adjust the batch size based on your requirements
      List<Future<void>> uploadFutures = [];
      int totalImagesInBatch = images.length;
      int uploadedImages = 0;
      DateTime startTime = DateTime.now();
      // Process images in batches
      showLog("folderModelDoomsday1");
      for (int i = 0; i < images.length; i += batchSize) {
        folder = await folderModelDao.getFolderWhereCode(folderCode);
        showLog("folderModelDoomsday2");
        if (folder?.uploadStatus != null && folder?.uploadStatus != 1) {
          showLog('uploadStopped ${folder?.uploadStatus} ');
          Platform.isWindows
              ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
              : null;
          uploadState.value = false;
          return;
        }

        UploadState? uploadStatus = await uploadStatusDao
            .getUploadStateWhereAlbumName( folderName);
        if (uploadStatus == null) {
          var event =  eventModelDao.getEventWhereCode(eventCode);

          uploadStatusEntity.add(UploadState(
              eventName: event?.name,
              albumName: folderName,
              remainingFilesCount: images.length,
              totalFilesCount: totalFiles.length,
              uploadComplete: false));
          await uploadStatusDao.insertUploadStatus(uploadStatusEntity);
        }
        List<PhotoSelectionImage> batchImages = images.sublist(
            i, i + batchSize < images.length ? i + batchSize : images.length);

        // Process each image in the batch concurrently
        for (PhotoSelectionImage image in batchImages) {
          if (image.uploaded == true) {
            showLog('Image ${image.name} already uploaded, skipping...');
            continue;
          }

          uploadFutures.add(_processImage(image, folderCode, uploadedImages));
          imageName = image.name;
          List<PhotoSelectionImage>? remainingFileCount =
              await imageModelDao.getImagesNotuploaded(folderCode);
           uploadStatusDao.updateUploadStateWhereAlbumName(
              albumName: folderName,
              uploadingName: imageName ?? '',
              remainingFileCount: remainingFileCount?.length ?? 0);
          showLog('updateUploadStateWhereAlbumName ${image.uploaded}');
          controller.startProcessing();
          controller.progress.value = image.name!;
          showLog('getUploadedImages ${controller.progress.value}');
        }

        await Future.wait(uploadFutures);
        await Future.delayed(Duration.zero);
        uploadFutures.clear();
        batchSize = await deviceUtil.calculateBatchSize();
        showLog('Wait for all images in the batch to be processed $batchSize');
      }

     UploadState? uploadStatus =  uploadStatusDao
          .getUploadStateWhereAlbumName( folderName);
      if (uploadStatus != null) {
         uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: folderName, uploadingName: '', remainingFileCount: 0);
      }

      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
    } catch (e, s) {
      showLog('exception in uploadImagesInThisFolder $e & $s');
    }
  }

  Future<void> _processImage( PhotoSelectionImage image, String folderCode,
      int uploadedImages) async {
    String path = image.path ?? '$routePath/${image.name}';
    Uint8List? uInt8list;
    showLog("Going to compress: $path");
    try {
      uInt8list = await compressTheFile(File(path));
    } catch (e, s) {
      await deviceUtil.callChatNotifier('$e', '$s');
      uInt8list = await ImageUtil.compressImageToUint8List(path, 3);
      showLog('Error in compressing the image:  ....$e ,$s ');
    }

    if (uInt8list != null) {
      String? extension = lookupMimeType(path)?.split('/').last;
      int imageSizeBytes = uInt8list.length;
      DateTime uploadStartTime = DateTime.now();
      DigitalOceanSpacesService service = DigitalOceanSpacesService(
          originalFilePath: pmFilePath ?? "photomall");
      ImageSize size = await service.getImageDimensions(uInt8list);
      showLog('Image ImageSize: ${size.height} X ${size.width}');
      String uniqueImageName = image.sha256!;
      UploadFileResponse uploadFileResponse = await service.uploadFile(
          path: image.path ?? '',
          bytes: uInt8list,
          objectKey: uniqueImageName,
          extension: extension!,
          eventCode: eventCode,
          ableCode: folderCode,
          ableType: 'folders');
      final imageUrl = await service.getFileUrl(uniqueImageName);
      showLog('Image URL: $imageUrl');
      if (uploadFileResponse.hash != '' &&
          uploadFileResponse.preSignedURlCode != '') {
        String? uploadImageHash = uploadFileResponse.hash;
        String? preSignedUrlCode = uploadFileResponse.preSignedURlCode;

        ImageUploadResponse? imageUploadResponse = await uploadImageApiCall(
            path: image.path!,
            folderCode: folderCode,
            image: uniqueImageName,
            studioCode: studioCode,
            fileName: pathq.basename(path),
            filePath: pmFilePath!,
            imageHash: uploadImageHash,
            imageWidth: size.width.toString(),
            imageHeight: size.height.toString(),
            screenDisplay: '2',
            extension: extension,
            preSignedUrlCode: preSignedUrlCode);
        uInt8list = null;

        /// Calculate the upload speed
        int uploadTimeSeconds =
            DateTime.now().difference(uploadStartTime).inSeconds;

        /// Ensure at least 1 second elapsed time to avoid division by zero
        uploadTimeSeconds = uploadTimeSeconds > 0 ? uploadTimeSeconds : 1;

        double uploadSpeed =
            (imageSizeBytes / 1024) / uploadTimeSeconds; // KB/s
        controller.uploadSpeed.value = uploadSpeed;
        showLog('Upload speed: ${uploadSpeed.toStringAsFixed(2)} KB/s');
        if (imageUploadResponse != null && imageUploadResponse.file != null) {
          await imageModelDao.updateImageUploadedStatusTrue(
            image.id,
            imageUploadResponse.file!.code!,
            path,
          );
        } else {
          await InterNetProvider.waitForInternet();
          showLog('ImageUploadResponse is null, so restart upload');
          DeviceUtil deviceUtil = DeviceUtil();
          await deviceUtil.callChatNotifier(
              'imageUploadResponse error ', '$imageUploadResponse');
          Platform.isWindows
              ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
              : null;

          await Future.delayed(const Duration(seconds: 5));
          //await uploadImagesInThisFolder(folderCode);
        }
      } else {
        if (uploadFileResponse.hash == "Already Uploaded") {
          showLog("Already uploaded hash folders");
          await imageModelDao.updateImageUploadedStatusTrue(image.id, '', path);
        }
      }
    }
  }

/*
  Future<void> _processImage(appDb.PhotoSelectionImage image, String folderCode,
      int uploadedImages) async {
    String path = image.path ?? '$routePath/${image.name}';

    /// Generate hash for the image
    String hash = ''; //await generateImageHash(File(path));
    List<String?> dbHash = await imageModelDao.getSha256ForImages(folderCode);
    showLog('hash is $hash');
    Uint8List? uInt8list;
    showLog(" going to compress2 $path");

    //if (!dbHash.contains(hash)) {

    // Compress and encode the image
    try {
      uInt8list = await compressTheFile(File(path));
    } catch (e, s) {
      showLog('error in uploadImagesInThisFolder $e .... $s');
    }
    if (uInt8list != null) {
      String? extension = lookupMimeType(path);
      if (extension != null) {
        extension = extension.split('/').last;
      }
      String base64encodeIMage = base64Encode(uInt8list);

      /// Upload the image
      ImageUploadResponse? imageUploadResponse = await uploadImageApiCall(
          path: image.path!,
          folderCode: folderCode,
          image: 'data:image/$extension;base64,$base64encodeIMage',
          studioCode: studioCode,
          fileName: path.split('/').last);

      if (imageUploadResponse != null) {
        // Update image uploaded status in the database
        await imageModelDao.updateImageUploadedStatusTrue(
            image.id, imageUploadResponse.file!.code!, path, hash);
      } else {
        showLog('ImageUploadResponse is null');
      }
    }
  }
*/

  //}

  getAlertDialogValues() async {
    //ImageModelDao imageModelDao = ImageModelDao();
    pendingImagesForUpload =
        await imageModelDao.getImagesNotuploaded(folderCode);
    showLog('Alert dialog images ${pendingImagesForUpload?.length}');

    if (pendingImagesForUpload!.isEmpty) {
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
      await folderModelDao.updateUploadStatus(2, folderCode);
      uploadState.value = false;
      controller.stopProcessing();
      isFolderListeningStoped = true;
      return isAlertDialog = true;
    } else {}
  }

  bool checkAlreadyExist(int id) {
    bool status = false;
    for (var element in valueNotifierPhotoSelectionImages.value) {
      if (element.id == id) {
        status = true;
        return status;
      }
    }
    return status;
  }

  bool checkAlreadyExist1(int id) {
    Set<int> idSet =
        Set<int>.from(valueNotifierPhotoSelectionImages.value.map((e) => e.id));

    return idSet.contains(id);
  }

/*  Future<void> checkListInPath(String path, String folderCode) async {
    String directory = path;
    List<FileSystemEntity> files = Directory("$directory/").listSync();
    List<String> newImages = [];
    List<String> dbImages = [];
    appDb.Folder folder =
    await folderModelDao.getFolderFilesCount(folderCode: folderCode);
    List<appDb.PhotoSelectionImage>? images =
    await imageModelDao.getImagesNotuploaded(folderCode);
    int? dbFilesCount = folder.filesCount;
    int storageFilesCount = files.length;
    showLog(
        'folder fi1les Count $dbFilesCount  $storageFilesCount 7&& & ${images!
            .isNotEmpty}');

    if (dbFilesCount != null) {
      if ((dbFilesCount != storageFilesCount) || (images!.isNotEmpty)) {
        for (var element in valueNotifierPhotoSelectionImages.value) {
          if (element.name != null) {
            dbImages.add(element.name!);
          }
        }

        for (FileSystemEntity fileSystemEntity in files) {
          String? extension = lookupMimeType(fileSystemEntity.path);
          if (extension != null) {
            extension = extension
                .split('/')
                .last;
          }
          bool isDirectory =
          FileSystemEntity.isDirectorySync(fileSystemEntity.path);
          if ((extension == 'jpeg' || extension == 'jpg') && !isDirectory) {
            newImages.add(fileSystemEntity.path
                .split('/')
                .last); // name
          }

          showLog(
              "some photos has been added ${fileSystemEntity.path
                  .split('/')
                  .last}");
        }
        LocalDirectoryController localDirectoryController =
        LocalDirectoryController();
        localDirectoryController.upsertLocalImages(
          dbImages,
          newImages,
              (String string, List<String>? list) async {
            ImageModelDao imageModelDao = ImageModelDao();

            if (string == createImage) {
              List<appDb.PhotoSelectionImagesCompanion> companions = [];
              for (String data in list!) {
                companions.add(appDb.PhotoSelectionImagesCompanion(
                    folderCode: drift.Value(folderCode),
                    path: drift.Value(files
                        .where(
                            (element) =>
                        element.path
                            .split('/')
                            .last == data)
                        .first
                        .path),
                    name: drift.Value(data
                        .split('/')
                        .last),
                    code: const drift.Value(null),
                    lastUpdatedAt: const drift.Value(0),
                    uploaded: const drift.Value(false) // api
                ));
              }
              if (companions.isNotEmpty) {
                await imageModelDao.insertAllImages(
                    imagesCompanion: companions);
              }
              setBusy(false);

              await uploadImagesInThisFolder(folderCode);
              setBusy(false);
            }
            showLog("update images ..Out");
            if (string == updateImage) {
              showLog("update images ..");
              setBusy(false);

              await uploadImagesInThisFolder(folderCode);
              setBusy(false);
            }
          },
        );
        await folderModelDao.updateFilesCount(
            folderCode: folderCode, filesCount: files.length);
      } else {
        showLog("checkListInPath folder is already in sync");
      }
    }
  }*/

  void listenLocalDirectory({required String folderCode}) {
    if (routePath != null && routePath!.isNotEmpty) {
      Timer.periodic(localDirectoryListenTime, (Timer timer) {
        if (isFolderListeningStoped) {
          showLog('canceled listening..');
          timer.cancel();
        } else {
          //checkListInPath(routePath!, folderCode);
          getAlertDialogValues();
        }
      });
    }
  }

  void imagesTableListen(String folderCode) {
    String path = "";
    Stream<List< PhotoSelectionImage>> streamPhotoSelectionImages =
        imageModelDao.streamImagesWhereFolderCode(folderCode);
    showLog('imageRows stream $streamPhotoSelectionImages');
    streamPhotoSelectionImages.listen((streamPhotoSelectionImagesEvent) async {
      showLog("image value listening");
      for ( PhotoSelectionImage photoSelectionImage
          in streamPhotoSelectionImagesEvent) {
        showLog("value loop \n ${photoSelectionImage.path}");

        if (!valueNotifierPhotoSelectionImages.value
            .contains(photoSelectionImage)) {
          showLog("value listening added ${photoSelectionImage.name} ");
          bool status = checkAlreadyExist(photoSelectionImage.id);
          if (status) {
            valueNotifierPhotoSelectionImages.value
                .removeWhere((element) => element.id == photoSelectionImage.id);
          }
          if (photoSelectionImage.path == null ||
              (photoSelectionImage.path != null &&
                  photoSelectionImage.path!.isEmpty)) {
            showLog('imagePath is ${photoSelectionImage.path}');
            path = '$routePath/${photoSelectionImage.name}';
          } else {
            path = photoSelectionImage.path!;
          }
          valueNotifierPhotoSelectionImages.value.add(PhotoSelectionImage(
              uploaded: photoSelectionImage.uploaded,
              name: photoSelectionImage.name,
              path: path,
              code: photoSelectionImage.code,
              folderCode: photoSelectionImage.folderCode,
              lastUpdatedAt: photoSelectionImage.lastUpdatedAt,
              id: photoSelectionImage.id));

          setBusy(false);
        }
      }
    });
  }

  Future<void> getImagesTable(String folderCode) async {
    String path = "";
    List<PhotoSelectionImage>? streamPhotoSelectionImages =
        await imageModelDao.getImagesWhereFolderCode(folderCode);

    showLog('getImagesTable stream streamPhotoSelectionImages');
    showLog("getImagesTable image value listening");

    List< PhotoSelectionImage> newImages = [];
    if (streamPhotoSelectionImages != null &&
        streamPhotoSelectionImages.isNotEmpty) {
      for (PhotoSelectionImage photoSelectionImage
          in streamPhotoSelectionImages) {
        showLog("getImagesTable value loop \n ${photoSelectionImage.path}");

        // Check for duplicates
        if (!valueNotifierPhotoSelectionImages.value
            .contains(photoSelectionImage)) {
          showLog(
              "getImagesTable value listening added ${photoSelectionImage.name} ");
          bool status = checkAlreadyExist1(photoSelectionImage.id);

          if (status) {
            valueNotifierPhotoSelectionImages.value
                .removeWhere((element) => element.id == photoSelectionImage.id);
          }

          if (photoSelectionImage.path == null ||
              (photoSelectionImage.path != null &&
                  photoSelectionImage.path!.isEmpty)) {
            showLog('getImagesTable imagePath is ${photoSelectionImage.path}');
            path = '$routePath/${photoSelectionImage.name}';
          } else {
            path = photoSelectionImage.path!;
          }

          newImages.add(PhotoSelectionImage(
              uploaded: photoSelectionImage.uploaded,
              name: photoSelectionImage.name,
              path: path,
              code: photoSelectionImage.code,
              sha256: photoSelectionImage.sha256,
              folderCode: photoSelectionImage.folderCode,
              lastUpdatedAt: photoSelectionImage.lastUpdatedAt,
              id: photoSelectionImage.id));
        }
      }

      // Add new images in batches
      valueNotifierPhotoSelectionImages.value.addAll(newImages);
    }

    scrollController.addListener(() {
      /*Random random = Random();
      _progressController.add(ImageUploadProgress(
          '5252 $imageName', random.nextInt(50).toDouble()!));*/
      showLog('scrolling...xyz');
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        showLog("End of list");
        addPhotosToList();
      }
    });

    int comparison = valueNotifierPhotoSelectionImages.value!.length >= 15
        ? 15
        : valueNotifierPhotoSelectionImages.value!.length;

    for (int i = 0; i < comparison; i++) {
      showLog('add localValueNotifierPhotoSelectionImages');
      localValueNotifierPhotoSelectionImages.value
          .add(valueNotifierPhotoSelectionImages.value![i]!);
    }

    setBusy(true);
  }

  Future<void> folderTableListen(String folderCode) async {
    List<Folder> folders =
        await folderModelDao.getSubFolderWhereParent(folderCode);
    showLog("the data >232> $folderCode");
    //folders.listen((folderEvent) {

    for (Folder folder in folders) {
      if (!folderList.value.contains(folder)) {
        folderList.value.add(folder);
      }
    }
    // });
  }

  Future<void> folderTableListen1(String folderCode) async {
    setBusy(false);
    List<Folder> folders =
        await folderModelDao.getSubFolderWhereParent(folderCode);
    showLog("the data >232> $folderCode");
    //folders.listen((folderEvent) {
    showLog("the data >>123 ${folders.length}");
    for (Folder folder in folders) {
      if (!folderList.value.contains(folder)) {
        folderList.value.add(folder);
      }
    }
    setBusy(false);

    // });
  }

  String? getExtension(FileSystemEntity file) {
    String? extension = lookupMimeType(file.path);
    if (extension != null) {
      return extension.split('/').last;
    } else {
      return null;
    }
  }

  setSegregationFormat(String value) async {
    await folderModelDao.updateSegregationFormat(folderCode, value);
  }

  setSegregationPath(String value) async {
    isLoading = true;
    setBusy(false);
    await folderModelDao.updateSegregationPath(folderCode, value);
    folderSegritionPath = value;
    isLoading = false;
    setBusy(false);
  }

  setCustomSegregationPath(String value) async {
    isLoading = true;
    setBusy(false);
    await folderModelDao.updateCustomSegregationPath(folderCode, value);
    folderCustomSegritionPath = value;
    isLoading = false;
    setBusy(false);
  }

  Stream<List<PhotoSelectionImage>>
      streamPhotoSelectionImagesForView() async* {
    Stream<List<PhotoSelectionImage>>? streamPhotoSelectionImages =
        imageModelDao.streamImagesWhereFolderCode(folderCode);
    await for (List<PhotoSelectionImage> images
        in streamPhotoSelectionImages) {
      final filteredImages =
          images.where((image) => image.preSignedURlCode != null).toList();
      showLog("Filtered list length: ${filteredImages.length}");

      yield filteredImages;
    }
  }

  Future<void> updateUploadStatus(String folderCode) async {
    uploadState.toggle();
    isUploadingFolders.remove(folderCode);
    if (folderCode.isEmpty) {
      showLog("Error: folderCode is empty.");
      return;
    }

    // Fetch the folder before updating status
    folder = await folderModelDao.getFolderWhereCode(folderCode);
    if (folder == null) {
      showLog("Error: Folder not found for code $folderCode");
      return;
    }

    // Toggle uploadStatus (2 → 1 or 1 → 2)
    int newStatus = (folder!.uploadStatus == 2) ? 1 : 2;
    await folderModelDao.updateUploadStatus(newStatus, folderCode);

    // Fetch updated folder info
    folder = await folderModelDao.getFolderWhereCode(folderCode);

    if (folder?.uploadStatus == 1) {
      isUploadingFolders.add(folderCode!);
      images.clear();
      await uploadImagesInThisFolder(folderCode);
    }

    // Properly toggle the observable state
  }
}

class FolderViewModel {
  String? code;
  String name;
  String? path;

  FolderViewModel({this.code, required this.name, required this.path});
}

class ImageViewModel {
  String path;
  String name;
  bool uploaded;

  ImageViewModel(
      {required this.path, required this.name, required this.uploaded});
}

class FolderCreate {
  final String? folderCode;
  final bool status;

  FolderCreate({this.folderCode, required this.status});
}

class ImageUploadProgress {
  final String imageName;
  final double progress;

  ImageUploadProgress(this.imageName, this.progress);
}
