// Ensure this at the top
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../api/apiRequestModels/digital_oceans_space_service.dart';
import '../api/apiResponseModels/image_upload.dart';
import '../api/apiResponseModels/pre_signed_url_api_response_model.dart';
import '../api/api_call.dart';

import '../main.dart';
import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';
import '../routes/1.constants/common_constants.dart';
import '../utils/device_util.dart';
import '../utils/file_utils.dart';
import '../utils/image_util.dart';
import '../database/object_box_model/object_box_models.dart';

class ImageFileUploader {
  final eventModelDao = objectBox.eventModelDao;

  void runInIsolates() async {
    compressAndSaveImages();

    uploadImageToSpaces();

  }

  static Future<void> compressAndSaveImages() async {

    while (true) {
      showLog("compressAndSaveImages while");
      try {


        final orderModelDao = objectBox.orderModelDao;
        List<OrderImage>? orders =
            orderModelDao.getAndReserveImageForCompression();

        if (orders != null) {
          await processInBatches<OrderImage>(
            orders,
            (order) async {
              //showLog("compressAndSaveImages processInBatches ${order.id}");
              //orderModelDao.updateImageCompressionStatus(1, order.id);

              await ParallelImageUploader().compressImage(
                order,
              );
            },
          );

        }

        // sendPort.send("Compression Completed");
      } catch (e) {
        // sendPort.send("Error in Compression: $e");
        showLog("Error in compressAndSaveImages: $e");
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  updateUploadStatus(
      String eventCode, String albumCode, String albumName) async {
    showLog("updateUploadStatus $eventCode $albumCode");
    final uploadStatusDao = objectBox.uploadStatusDao;

    final orderModelDao = objectBox.orderModelDao;
    List<OrderImage> imagesUpload = [];
    imagesUpload =
        orderModelDao.getImagesWhereAlbumCodeWhereNotUploaded(albumCode) ?? [];

    List<UploadState> uploadStatusEntity = [];
    List<OrderImage>? totalFiles =
        orderModelDao.getImagesWhereAlbumCode(albumCode);

    UploadState? uploadStatus =
        uploadStatusDao.getUploadStateWhereAlbumName(albumName);
    showLog(
        "updateUploadStatus remainingFileCount imagesUpload uploadStatus $albumName");

    if (uploadStatus == null) {
      var event = await eventModelDao.getEventWhereCode(eventCode);

      uploadStatusEntity.add(UploadState(
          eventName: event?.name,
          totalFilesCount: totalFiles?.length,
          albumName: albumName,
          remainingFilesCount: imagesUpload.length,
          uploadComplete: false));
      showLog("insertUploadStatus uploadStatusEntity $albumName");

      await uploadStatusDao.insertUploadStatus(uploadStatusEntity);
    } else {
      uploadStatusDao.updateUploadStateWhereAlbumName(
          albumName: albumName,
          uploadingName: '' ?? '',
          remainingFileCount: imagesUpload!.length);
      showLog(
          "updateUploadStateWhereAlbumName ${imagesUpload.length} $albumName");
    }
  }

  static Future<void> uploadImageToSpaces() async {
    while (true) {
      showLog("uploadImageToSpaces while");
      try {
        final orderModelDao = objectBox.orderModelDao;
        List<OrderImage>? orders = orderModelDao.getImageForUpload();
        showLog("uploadImageToSpaces while  ${orders?.length}");

        if (orders != null) {
          await processInBatches<OrderImage>(
            orders,
            (order) => ParallelImageUploader().uploadImage(
              order,
            ),
          );
        }

        // sendPort.send("Upload Completed");
      } catch (e) {
        //  sendPort.send("Error in Upload: $e");
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }



  static Future<void> processInBatches<T>(
    List<T> items,
    Future<void> Function(T item) task,
  ) async {
    int batchSize = 6; //await DeviceUtil().calculateBatchSize();
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(task));
    }
  }

  Future<void> uploadImageFileFromAppFolderToSpace(FileSystemEntity file,
      String eventCode, int screenDisplay, OrderImage order,
      {bool isForDisplay = false, String largeJvtFileCode = ''}) async {
    try {
      String pmFilePath = await PreferenceHelper.getString(originalFilePathKey);
      String studioCode = await PreferenceHelper.getString(studioCodePrefKey);
      String baseName = path.basename(file.path);
      if (!(file.path).contains(order.name!)) {
        return;
      }
      if (baseName.contains("Ai_screenDisplay_2-") && isForDisplay == false) {
        final orderModelDao = objectBox.orderModelDao;

        Directory appDir = await getApplicationCacheDirectory();
        String? aiPath = await findAiImagePath(appDir, order.name!);
        OrderImage? orderImage = orderModelDao.getImageWhereId(order.id);
        showLog("Ai_screenDisplay_2 aiPath : $aiPath");
        if (aiPath != null &&
            aiPath.isNotEmpty &&
            orderImage != null &&
            orderImage.code != null) {
          await uploadImageFileFromAppFolderToSpace(
                  File(aiPath), eventCode, 2, order,
                  isForDisplay: true, largeJvtFileCode: orderImage.code!)
              .then((b) async => orderModelDao.updateImageUploadedStatusTrue(
                    order.id,
                    2,
                    code: orderImage.code!,
                    path: order.path!,
                  ));
        }
        return;
      } else {
        showLog("continue: $baseName");
      }

      DigitalOceanSpacesService service = DigitalOceanSpacesService(
          originalFilePath: pmFilePath ?? "photomall");
      Uint8List uint8list = await getUint8ListFromFile(File(file.path));
      String uniqueImageName =
          isForDisplay == false ? order.sha256! : order.screenDisplay2ImageUrl!;
      String ratio = file.path.split('-').last;
      String? extension = lookupMimeType(file.path);

      ImageSize size = await service.getImageDimensions(uint8list);
      Api api = Api(null);

      UploadFileResponse uploadFileResponse = await service.uploadFile(
        path: order.path!,
        bytes: uint8list,
        objectKey: uniqueImageName,
        extension: extension ?? "jpeg",
        eventCode: eventCode,
        ableCode: order.albumCode,
        ableType: "albums",
        ratio: ratio,
        isFromCompressForScreenDisplay2: screenDisplay == 2,
        isFromCompute: isForDisplay,
      );
      ImageUploadResponse? response;
      if (uploadFileResponse.hash.isNotEmpty ?? false) {
        if (uploadFileResponse.hash != '' &&
            uploadFileResponse.hash != 'Already Uploaded') {
          response = await api.imageUploadApiCall(
            type: 'albums',
            ableCode: order.albumCode,
            filePath: pmFilePath,
            studioCode: studioCode,
            jvtFileName: uniqueImageName,
            fileName: order.name!,
            imageHash: uploadFileResponse.hash,
            eventCode: eventCode,
            extension: extension ?? "jpeg",
            preSignedUrlCode: uploadFileResponse.preSignedURlCode,
            screenDisplay: screenDisplay.toString(),
            imageWidth: size.width.toString(),
            imageHeight: size.height.toString(),
            ratio: ratio,
            isFromCompressForScreenDisplay2: isForDisplay,
            largeJvtFileCode: largeJvtFileCode,
          );
        } else {
          return;
        }

        if (response != null) {
          final orderModelDao = objectBox.orderModelDao;
          await deleteFile(file.path);
          orderModelDao.updateImageFileCode(
              order.id, response.file!.jvtFileCode!);
          if (screenDisplay == 2 && isForDisplay == false) {
            orderModelDao.updateImageUploadedStatusTrue(
              order.id,
              2,
              code: response.file!.jvtFileCode!,
              path: order.path!,
            );
            return;
          }
          showLog("screenDisplay inter $screenDisplay");
          if (screenDisplay == 4 && isForDisplay == false) {
            final orderModelDao = objectBox.orderModelDao;
            Directory appDir = await getApplicationCacheDirectory();
            String? aiPath = await findAiImagePath(appDir, order.name!);
            OrderImage? orderImage = orderModelDao.getImageWhereId(order.id);
            showLog("aiPath : $aiPath");
            if (aiPath != null && aiPath.isNotEmpty) {
              await uploadImageFileFromAppFolderToSpace(
                      File(aiPath), eventCode, 2, order,
                      isForDisplay: true,
                      largeJvtFileCode:
                          response.file!.jvtFileCode ?? orderImage!.code!)
                  .then(
                      (b) async => orderModelDao.updateImageUploadedStatusTrue(
                            order.id,
                            2,
                            code: orderImage?.code!,
                            path: order.path!,
                          ));
            }
          }
        }
      }
    } catch (e) {
      showLog("Upload error: $e");
    }
  }

  Future<String?> findAiImagePath(Directory appDir, String orderName) async {
    try {
      showLog("findAiImagePath $orderName");
      await for (FileSystemEntity entity in appDir.list()) {
        if (entity is File &&
            entity.path.contains('Ai_screenDisplay_2-$orderName')) {
          return entity.path;
        }
      }
    } catch (e) {
      print('Error while searching for file: $e');
    }
    return null; // Return null if no matching file is found
  }

  Future<Uint8List> getUint8ListFromFile(File file) async {
    return await file.readAsBytes();
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      showLog('Deleted file at $filePath');
    }
  }
}

class ParallelImageUploader {
  final orderModelDao = objectBox.orderModelDao;
  final eventModelDao = objectBox.eventModelDao;
  final rootIsolateToken = RootIsolateToken.instance!;
  Api api = Api(null);
  int _offset = 0;

// Launch multiple workers
//   void startWorkers({int workerCount = 5}) {
//     for (int i = 0; i < workerCount; i++) {
//       _startWorker(i);
//     }
//   }

  static Future<void> processInBatches<T>(
    List<T> items,
    Future<void> Function(T item) task,
  ) async {
    int batchSize = 6; //await DeviceUtil().calculateBatchSize();
    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(task));
    }
  }




  compressImage(OrderImage? order) async {
    Events? event;
    showLog("compressImage offset: $order");
    if (order != null) {
      //_offset++;
      showLog(
          "compressImage:ParallelImageUploader offset: ${order.id}:${order.name}");

      showLog("order:$order");

      event = eventModelDao.getEventWhereCode(order.eventCode ?? "");

      Compression? compressed = await runCompressionInIsolate(
        filePath: order.path!,
        token: rootIsolateToken,
        screenDisplay: event?.screenDisplay ?? 2,
      );

      if (compressed != null && compressed.uint8list != null) {
        print("Compression ratio: ${compressed.ratio}");
       // orderModelDao.updateImageCompressionStatus(2, order.id);
        orderModelDao.updateImageBytes(
            order.id, compressed.uint8list, compressed.ratio);
      } else {
       // orderModelDao.updateImageCompressionStatus(4, order.id);
      }
    } else {
      showLog("compressImage:order is $order");
    }
  }



  Future<Compression?> runCompressionInIsolate({
    required String filePath,
    required RootIsolateToken token,
    required int screenDisplay,
  }) async {
    final receivePort = ReceivePort();

    // await Isolate.spawn(
    Compression compression = await compressionIsolateEntry(
      {
        'sendPort': receivePort.sendPort,
        'filePath': filePath,
        'token': token,
        'screen_display': screenDisplay,
      },
    );

    //final result = await receivePort.first;
    //receivePort.close();

    return compression;
  }

  compressionIsolateEntry(Map<String, dynamic> message) async {
    SendPort sendPort = message['sendPort'];
    final RootIsolateToken token = message['token'];
    String filePath = message['filePath'];
    int screenDisplay = message['screen_display'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final file = File(filePath);
    Compression? compression;
    try {
      FileUtil fileUtil = FileUtil();
      ImageCompressionInIsolate imageCompressionInIsolate =
          ImageCompressionInIsolate();

      ImageSize studioSize = await fileUtil.getStudioSize(screenDisplay);

      compression = await compute(imageCompressionInIsolate.compressTheFile, {
        'file': File(filePath),
        'height': studioSize.height,
        'width': studioSize.width
      });

      // if (compression?.uint8list == null) {
      //   final fallback =
      //       await ImageUtil.compressImageToUint8List(filePath, screenDisplay);
      //   compression = Compression(fallback, "1");
      // }
    } catch (e, s) {
      showLog('Compression error: $e ,$s');
      /* orderModelDao.updateImageCompressionStatus(4, order.id);
      if (e.toString().contains("RangeError")) {
        orderModelDao.updateImageCompressionStatus(5, order.id);
      }*/
    }

    double ratio = double.parse(compression?.ratio ?? "0");
    final result =
        Compression(compression?.uint8list, ratio.toStringAsFixed(2));

    return result;
  }

  uploadImage(OrderImage order) {
    showLog("uploadImage-ParallelImageUploader");
    Events? event;

    if (order != null) {
      showLog(
          "uploadImage-uploadImage order Image:${order.name}:${order.screenDisplay2imageBytes?.length}");

      event = eventModelDao.getEventWhereCode(order.eventCode ?? "");
      uploadImageFileToSpace(
          File(order.path!), order.eventCode!, event!.screenDisplay, order);
    }
  }



  Future<void> uploadImageFileToSpace(FileSystemEntity file, String eventCode,
      int screenDisplay, OrderImage order,
      {bool isForDisplay = false, String largeJvtFileCode = ''}) async {
    try {
      String pmFilePath = await PreferenceHelper.getString(originalFilePathKey);
      String studioCode = await PreferenceHelper.getString(studioCodePrefKey);
      String baseName = path.basename(file.path);
      if (!(file.path).contains(order.name!)) {
        return;
      }

      DigitalOceanSpacesService service =
          DigitalOceanSpacesService(originalFilePath: pmFilePath);
      Uint8List uint8list = isForDisplay == true
          ? order.screenDisplay2imageBytes!
          : order.imageBytes!;
      String uniqueImageName =
          isForDisplay == false ? order.sha256! : order.screenDisplay2ImageUrl!;
      String? ratio =
          isForDisplay == true ? order.ratio : order.screenDisplay2ratio;
      String? extension = lookupMimeType(file.path);

      ImageSize size = await service.getImageDimensions(uint8list);
      Api api = Api(null);

      UploadFileResponse uploadFileResponse = await service.uploadFile(
        path: order.path!,
        bytes: uint8list,
        objectKey: uniqueImageName,
        extension: extension ?? "jpeg",
        eventCode: eventCode,
        ableCode: order.albumCode,
        ableType: "albums",
        ratio: ratio!,
        isFromCompressForScreenDisplay2: screenDisplay == 2,
        isFromCompute: isForDisplay,
      );
      ImageUploadResponse? response;
      if (uploadFileResponse.hash.isNotEmpty ?? false) {
        if (uploadFileResponse.hash != '' &&
            uploadFileResponse.hash != 'Already Uploaded') {
          response = await api.imageUploadApiCall(
            type: 'albums',
            ableCode: order.albumCode,
            filePath: pmFilePath,
            studioCode: studioCode,
            jvtFileName: uniqueImageName,
            fileName: order.name!,
            imageHash: uploadFileResponse.hash,
            eventCode: eventCode,
            extension: extension ?? "jpeg",
            preSignedUrlCode: uploadFileResponse.preSignedURlCode,
            screenDisplay: screenDisplay.toString(),
            imageWidth: size.width.toString(),
            imageHeight: size.height.toString(),
            ratio: ratio,
            isFromCompressForScreenDisplay2: isForDisplay,
            largeJvtFileCode: largeJvtFileCode,
          );
        } else {
          return;
        }

        if (response != null) {
          final orderModelDao = objectBox.orderModelDao;
          isForDisplay == true
              ? orderModelDao.clearImageBytesForScreenDisplay2(order.id)
              : orderModelDao.clearImageBytes(order.id);
          orderModelDao.updateImageFileCode(
              order.id, response.file!.jvtFileCode!);
          if (screenDisplay != 4) {
            orderModelDao.updateImageUploadedStatusTrue(
              order.id,
              3,
              //code: response.file!.jvtFileCode!,
              path: order.path!,
            );
            return;
          }
        }
      }
    } catch (e) {
      showLog("Upload error: $e");
    }
  }
}
