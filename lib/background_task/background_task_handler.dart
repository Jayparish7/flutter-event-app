import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mime/mime.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:drift/drift.dart' as drift;
import 'package:photomall_studio_manager/database/model/app_db.dart' as appDb;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/apiRequestModels/digital_oceans_space_service.dart';
import '../api/apiResponseModels/image_upload.dart';
import '../api/api_call.dart';
import '../database/dao/order_dao.dart';
import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import '../preference/preference_constants.dart';
import '../utils/device_util.dart';
import '../utils/file_utils.dart';
import 'package:path/path.dart' as pathq;

import '../utils/image_util.dart';

class BackgroundTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';
  DeviceUtil deviceUtil = DeviceUtil();

  int _count = 0;
  String albumCode = '';
  String eventCode = '';
  String studioCode = '';
  Api? apiRepo;
  String path = '';
  String eventName = '';
  String albumName = '';
  final eventModelDao = objectBox.eventModelDao;

  final orderModelDao = objectBox.orderModelDao;
  final albumModelDao = objectBox.albumModelDao;


  FileUtil fileUtil = FileUtil();

  // Future<void> updateTaskData() async {
  //   List<UploadDetails> result = await orderModelDao.getEventName(albumCode);
  //   if (result.isNotEmpty) {
  //     List<appDb.Order>? uploadedImages =
  //         await orderModelDao.getImagesWhereAlbumCodeWhereUploaded(albumCode) ??
  //             [];
  //     _count = uploadedImages.length;
  //     showLog('uploaded Images _count ${result[0].albumName}');
  //     albumName = result[0].albumName;
  //     eventName = result[0].eventName;
  //   }
  //   // Update notification content.
  //   FlutterForegroundTask.updateService(
  //       notificationIcon: const NotificationIcon(
  //           metaDataName: "loading.png", backgroundColor: Colors.white),
  //       notificationTitle: '$eventName \n$albumName',
  //       notificationText: 'Uploaded Images: $_count',
  //       notificationButtons: [
  //         const NotificationButton(id: 'Stop', text: 'Stop Streaming')
  //       ]);
  //
  //   // Send data to main isolate.
  //   FlutterForegroundTask.sendDataToMain(_count);
  // }

  // getTaskData() async {
  //   List<UploadDetails> result = await orderModelDao.getEventName(albumCode);
  //   if (result.isNotEmpty) {
  //     List<appDb.Order>? uploadedImages =
  //         await orderModelDao.getImagesWhereAlbumCodeWhereUploaded(albumCode) ??
  //             [];
  //     _count = uploadedImages.length;
  //     showLog('uploaded Images _count ${result[0].albumName}');
  //     albumName = result[0].albumName;
  //     eventName = result[0].eventName;
  //   }
  // }

  uploadImagesInAndroid() async {
    apiRepo = Api(null);
    var prefs = await SharedPreferences.getInstance();
    showLog('album code {uploadImagesInAndroid}');

    List<String> codes = prefs.getStringList(eventCodeAlbumCodeKey) ?? [];
    showLog('album code {uploadImagesInAndroid} $codes');

    if (codes.isNotEmpty) {
      showLog('album code ${codes[0]}');
      showLog('event code ${codes[1]}');
      showLog('studio code ${codes[2]}');
      showLog('streamed path is  ${codes[3]}');
      studioCode = codes[2];
      albumCode = codes[0];
      eventCode = codes[1];
      path = codes[3];
      if (eventCode == '' || codes[1] == '' || path == '') {
        Album? album = await albumModelDao.getAlbumWhereCode(albumCode);
        showLog('eventCode  is null  $album}');

        if (album != null) {
          eventCode = album.eventCode;
          path = album.path ?? "";
          path = path.replaceAll(pathq.basename(path), '');
        }
      }
      showLog('eventCode  is $eventCode path is path $path ');

      await uploadSingleImageInThisFolder(eventCode);
      await insertPhotos(albumCode: codes[0], path: path, eventCode: eventCode);
    }
  }

  Future<void> uploadSingleImageInThisFolder(String eventCode) async {
    Album? album = await albumModelDao.getAlbumWhereCode(albumCode);

    if (album?.uploadStatus != null && album?.uploadStatus != 1) {
      showLog('uploadStopped ${album?.uploadStatus} ');
      return;
    }
    showLog('uploadSingleImageInThisFolder background');
    int eventScreenDisplay = 4;
    ImageSize studioSize = ImageSize(width: 2560, height: 1440);
    var event = await eventModelDao.getEventWhereCode(eventCode);
    eventScreenDisplay = event?.screenDisplay ?? 4;
    studioSize = await fileUtil.getStudioSize(event?.screenDisplay ?? 4);
    List<OrderImage>? images =
          orderModelDao.getImagesWhereAlbumCodeWhereNotUploaded(albumCode);
    showLog('uploadSingleImageInThisFolder: ${images?.length} ,,, $images');

    // If images exist and are not uploaded
    if (images != null && images.isNotEmpty) {
      // Get the path excluding the image name
      path = images.first.path!.replaceAll('/${images.first.name}', '');
      //listenToDirectory(path);

      // Get the first image in the list (only process one image)
      OrderImage image = images.first;
      showLog('uploadSingleImageInThisFolder: $image');

      // Retrieve the upload status of the album

      // Start processing the first image
      await _processImage(image, studioSize.width ?? 2560,
          studioSize.height ?? 1440, eventScreenDisplay.toString());

      // Update the status during upload

      // After uploading, check if there are no more images
    }
  }

  Future<void> _processImage(
     OrderImage image, int width, int height, String eventScreenDisplay,
      {bool isFromCompressForScreenDisplay2 = false,
      String largeJvtFileName = ''}) async {
    String pmFilePath = await PreferenceHelper.getString(originalFilePathKey);
    ImageCompressionInIsolate imageCompressionInIsolate =
        ImageCompressionInIsolate();

    String path = image.path ?? '';
    Uint8List? uint8list;
    Compression? compression;

    try {
      compression = await imageCompressionInIsolate.compressTheFile(
          {'file': File(path), 'height': height, 'width': width});
      if (compression != null) {
        uint8list = compression.uint8list;
      } else {
        return;
      }
    } catch (e, s) {
      showLog('_processImage --${image.name} $e--->$s');

      await deviceUtil.callChatNotifier('$e', '$s');
      if (e.toString().contains("Bad state: Should not initialize") ||
          e.toString().contains("AnyhowException")) {
          orderModelDao.updateImageUploadedStatusTrue(image.id,3, code: '',path:  path);
      }
    }
    if (uint8list != null) {
      String? extension = lookupMimeType(path);
      if (extension != null) {
        extension = extension.split('/').last;
      }
      DigitalOceanSpacesService service =
          DigitalOceanSpacesService(originalFilePath: pmFilePath);
      String uniqueImageName = (isFromCompressForScreenDisplay2 == false)
          ? image.sha256 ?? service.generateUniqueId()
          : service.generateUniqueId();
      showLog("image.sha256 ${image.sha256} $isFromCompressForScreenDisplay2");

      /// Upload the image
      UploadFileResponse uploadFileResponse = await service.uploadFile(
        ratio: compression!.ratio,
        path: image.path ?? '',
        bytes: uint8list,
        objectKey: uniqueImageName,
        extension: extension!,
        eventCode: eventCode,
        ableCode: albumCode,
        ableType: 'albums',
        isFromCompressForScreenDisplay2:
            (isFromCompressForScreenDisplay2 || eventScreenDisplay == '2'),
      );
      final imageUrl = await service.getFileUrl(uniqueImageName);
      showLog('Image URL:  $imageUrl');
      ImageUploadResponse? imageUploadResponse;
      ImageSize size = await service.getImageDimensions(uint8list);

      if (uploadFileResponse.hash != '' &&
          uploadFileResponse.preSignedURlCode != '') {
        String? uploadImageHash = uploadFileResponse.hash;
        String? preSignedUrlCode = uploadFileResponse.preSignedURlCode;
        showLog("uploadImageHash android $uploadImageHash");
        imageUploadResponse = await apiRepo!.imageUploadApiCall(
            type: 'albums',
            ableCode: albumCode,
            filePath: pmFilePath != '' ? pmFilePath : 'photomall',
            studioCode: studioCode,
            fileName: pathq.basename(path),
            jvtFileName: uniqueImageName,
            imageHash: uploadImageHash,
            preSignedUrlCode: preSignedUrlCode,
            screenDisplay: eventScreenDisplay,
            extension: extension,
            eventCode: eventCode,
            imageWidth: size.width.toString(),
            imageHeight: size.height.toString(),
            ratio: compression.ratio,
            isFromCompressForScreenDisplay2: isFromCompressForScreenDisplay2,
            largeJvtFileCode: largeJvtFileName);
        showLog("uploadImageHash android after api call :$imageUploadResponse");
      } else {
        if (uploadFileResponse.hash == "Already Uploaded") {
          showLog("Already uploaded hash android");
            orderModelDao.updateImageUploadedStatusTrue(image.id,2,code:  '', path: path);
        }
      }

      if (imageUploadResponse != null && imageUploadResponse.file != null) {
        if (eventScreenDisplay == '4' &&
            isFromCompressForScreenDisplay2 == false) {
          showLog(
              "isFromCompressForScreenDisplay2 init $isFromCompressForScreenDisplay2");
          Uint8List uint8list = await File(image.path!).readAsBytes();
          ImageSize imageSize = ImageSize(height: 1024, width: 2400);
          try {
            imageSize = await service.getImageDimensions(uint8list);
          } catch (e, s) {
            showLog("RangeError ${image.name}");
            await deviceUtil.callChatNotifier('imageSize $e', '$s');
            if (e.toString().contains("RangeError") ||
                e.toString().contains("Codec failed to produce an image")) {
                orderModelDao.updateImageUploadedStatusTrue(
                  image.id,3 ,code: '',path:  path);
            }
            return;
          }
          ImageSize resizeData = await fileUtil.getStudioSize(2);
          bool shouldResize;
          if (imageSize.width! >= imageSize.height!) {
            // Landscape
            showLog("Its a landscape");
            shouldResize = imageSize.width! < resizeData.width!;
          } else {
            // Portrait
            showLog("Its a portrait");

            shouldResize = imageSize.height! < resizeData.height!;
          }

          if (shouldResize) {
            showLog("Resizing needed");
            // Perform resize operation
            await _processImage(image, resizeData.width ?? 2560,
                    resizeData.height ?? 1440, "2",
                    isFromCompressForScreenDisplay2: true,
                    largeJvtFileName:
                        imageUploadResponse.file!.jvtFileCode ?? "")
                .then((value) async {
                orderModelDao.updateImageUploadedStatusTrue(
                  image.id,3,code:  imageUploadResponse?.file!.code!, path:  path);
            });
          } else {
            showLog("No resizing needed");
            await apiRepo!
                .imageUploadApiCall(
                    type: 'albums',
                    ableCode: albumCode,
                    filePath: pmFilePath,
                    studioCode: studioCode,
                    jvtFileName: uniqueImageName,
                    fileName: pathq.basename(path),
                    imageHash: uploadFileResponse.hash,
                    eventCode: eventCode,
                    extension: extension,
                    preSignedUrlCode: uploadFileResponse.preSignedURlCode,
                    screenDisplay: "2",
                    imageWidth: size.width.toString(),
                    imageHeight: size.height.toString(),
                    ratio: "1",
                    isFromCompressForScreenDisplay2: true,
                    largeJvtFileCode:
                        imageUploadResponse.file!.jvtFileCode ?? "")
                .then((value) async {
                orderModelDao.updateImageUploadedStatusTrue(
                  image.id,3,code:  imageUploadResponse?.file!.code!,path:  path);
            });
          }
        } else {
          showLog(
              "isFromCompressForScreenDisplay2 $isFromCompressForScreenDisplay2 ${image.path}");
            orderModelDao.updateImageUploadedStatusTrue(
              image.id,3,code:  imageUploadResponse.file!.code!,path:  path);
        }
      }
    }
  }

  Future<void> insertPhotos(
      {required String path,
      required String albumCode,
      required String eventCode}) async {
    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: "photomall");
    showLog("step 1 FileSystemCreateEvent $path 3");
    FileUtil fileUtil = FileUtil();
    String directory = path;
    List<OrderImage>? localOrders =
        await orderModelDao.getImagesWhereAlbumCode(albumCode) ?? [];

    List<String> localImages = [];
    if (localOrders.isNotEmpty) {
      for (int i = 0; i < localOrders.length; i++) {
        localImages.add(localOrders[i].name!);
        path = localOrders[i].path!.replaceAll('/${localOrders[i].name!}', '');

        if (localOrders[i].path!.isEmpty) {
          showLog('localOrders isEmpty ${localOrders[i].path!}');
            orderModelDao.deleteOrderWhereId(localOrders[i].id);
        }
      }
      showLog('localImages $localImages');
    }
    //directory = path;
    List<FileSystemEntity> images = [];
    List<FileSystemEntity> files = [];
    try {
      files = Directory("$directory/").listSync();
    } catch (e, s) {
      showLog('insertPhotos try catch $directory $s ');
    }
    for (var file in files) {
      bool isDirectory = FileSystemEntity.isDirectorySync(file.path);
      String? extension = fileUtil.getExtension(file);
      showLog("FileSystemEntity bg $file");
      if ((extension == 'jpeg' || extension == 'jpg') &&
          !isDirectory &&
          !pathq.basename(file.path).startsWith('.')) {
        images.add(file);
      }
    }
    images.sort((a, b) => a.path
        .split('/')
        .last
        .toLowerCase()
        .compareTo(b.path.split('/').last.toLowerCase()));

    showLog("step 2 ${images.length}");
    //int batchSize = 100;
    //int imageCount = images.length;
    if (images.isNotEmpty) {
      /*for (int i = 0; i < imageCount; i += batchSize) {
        List<FileSystemEntity> batch = images.sublist(
            i, i + batchSize < imageCount ? i + batchSize : imageCount);*/
      List<OrderImage> orders = [];
      {
        for (var element in files) {
          bool isDirectory = FileSystemEntity.isDirectorySync(element.path);
          String? extension = fileUtil.getExtension(element);
          if ((extension == 'jpeg' || extension == 'jpg') &&
              !isDirectory &&
              !pathq.basename(element.path).startsWith('.')) {
            if (!localImages.contains(element.path.split('/').last)) {
              orders.add(OrderImage(
                  eventCode: eventCode,
                  code: null,
                  path: element.path,
                  name: element.path.split('/').last,
                  uploaded: false,
                  sha256: service.generateUniqueId(),
                  albumCode: albumCode,
                  compressionStatus: 0,

              ),

              );
            } else {
              showLog('already in local images');
            }
          } else {
            showLog(
                "background extension is $extension and path is ${element.path}");
          }
        }

        await orderModelDao.insertAllOrders(orders);
        await albumModelDao.updateFilesCountWhereAlbumCode(
            code: albumCode, filesCount: files.length);
      }
      //}
      showLog("step 3 insert images");
    }
  }

  Future<ServiceRequestResult> _stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await FileUploadCredentials.setUploadCredentialsToPreference();
    showLog('onStart(starter: ${starter.name})');
    //updateTaskData();
  }

  bool isTaskRunning = false;

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) async {
    showLog("onRepeatEvent");
    if (isTaskRunning == true) return;

    isTaskRunning = true;
    try {
      await uploadImagesInAndroid();
      //await updateTaskData();
    } catch (e, s) {
      showLog("error in upload $e");
      await deviceUtil.callChatNotifier('onRepeatEvent$e', '$s');

      isTaskRunning = false;
    } finally {
      isTaskRunning = false;
    }

    /*  await getTaskData();
    showLog('onRepeatEvent --uploadImagesInAndroid ');
    FlutterForegroundTask.updateService(
      notificationTitle: 'Photomall Event Manager streaming the Event',
      notificationText: eventName,
    );*/
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    showLog('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    showLog('onReceiveData: $data');
    if (data == incrementCountCommand) {
      //updateTaskData();
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    showLog('onNotificationButtonPressed: $id');
    if (id == 'Stop') {
      showLog('stop streaming button pressed');
      _stopForegroundTask();
    }
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    showLog('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    showLog('onNotificationDismissed');
  }
}
