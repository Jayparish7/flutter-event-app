import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/album_show_responce.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/image_upload.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/controllers/order_controller.dart';
import 'package:photomall_studio_manager/image_uploader/image_file_uploader.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/file_utils.dart';
import 'package:photomall_studio_manager/utils/image_util.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as pathq;
import 'package:windows_taskbar/windows_taskbar.dart';

import '../../api/apiRequestModels/digital_oceans_space_service.dart';
import '../../common_widgets/common_appbar.dart';

import '../../database/object_box_model/object_box_models.dart';
import '../../main.dart';
import '../../preference/preference_constants.dart';
import '../../utils/device_util.dart';

class AlbumDetailedController extends BaseObserver {

  bool isLoading = false;
  int status = 0;
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;
  String _albumCode = '';
 String localEventCode ='';

  String _studioCode = '';



  String get albumCode => _albumCode;

  String get studioCode => _studioCode;

  var selectedPath = ''.obs;
  String? routePath;
  String? albumName;

  //  bool isFolderListeningStoped = false;
  ImageSize studioSize = ImageSize(width: 2560, height: 1440);
  int eventScreenDisplay = 4;
  final ProgressController controller;
  final orderModelDao = objectBox.orderModelDao;

  FileUtil fileUtil = FileUtil();
  ImageCompressionInIsolate imageCompressionInIsolate =
      ImageCompressionInIsolate();
  final ValueNotifier<List<OrderImage>> images =
      ValueNotifier<List<OrderImage>>([]);
  final ValueNotifier<List<OrderImage>> localImages =
      ValueNotifier<List<OrderImage>>([]);
  List<String> res = [];
  List<OrderImage> imagesUpload = [];
  ScrollController scrollController = ScrollController();
  final uploadStatusDao = objectBox.uploadStatusDao;

  DeviceUtil deviceUtil = DeviceUtil();
  final eventModelDao = objectBox.eventModelDao;

  List<UploadState> uploadStatusEntity = [];
  var imagesCount = '0';
  var isDirectoryExist = true.obs;
  final albumModelDao = objectBox.albumModelDao;
  Album? album;
  var uploadState = true.obs;
  List<OrderImage?>? pendingImagesForUpload;
  String? pmFilePath;
  String streamingPath = '';

  AlbumDetailedController({
    required this.controller,
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Future<void> getInitialValues(String albumCode, String studioCode,
      String path, String eventCode) async {
    try{
      localEventCode = eventCode;
      showLog("localEventCode $localEventCode");
      await FileUploadCredentials.setUploadCredentialsToPreference();

      pmFilePath = await PreferenceHelper.getString(originalFilePathKey);

      isLoading = true;
      setBusy(true);
      var event = await eventModelDao.getEventWhereCode(eventCode);
      eventScreenDisplay = event?.screenDisplay ?? 4;

      showLog(
          'studioSize is status $status ${studioSize.width} x ${studioSize
              .height}');
      _albumCode = albumCode;
      //_eventCode = eventCode;
      _studioCode = studioCode;
      status = await updateStatus();

      await listenAlbumImages();
      await getAlbum();
      //listenLocalDirectory();
      pendingImagesForUpload =
          orderModelDao.getImagesWhereAlbumCode(_albumCode);
      if (pendingImagesForUpload!.isNotEmpty) {
        streamingPath = pathq.dirname(pendingImagesForUpload!.first!.path!);
      }

      scrollController.addListener(() {
        showLog('scrolling...');
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          showLog("End of list");
          addPhotosToList();
        }
      });
      int comparison = images.value.length >= 25 ? 25 : images.value.length;
      for (int i = 0; i < comparison; i++) {
        localImages.value.add(images.value[i]);
        res.add(images.value[i].path!);
      }
      imagesCount = images.value.length.toString();
      if(images.value.isNotEmpty){
        selectedPath.value = images.value.first.path?.replaceAll(
                pathq.basename(images.value.first.path ?? ""), "") ??
            "";
      }
      if (true) {
        compressImagesInThisFolder(eventCode);
        uploadImagesInThisFolder(eventCode, albumCode);
        // await periodicTask(path);
      } else {
        showLog('codes in selectedPath.value ${selectedPath.value}');
        var prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(eventCodeAlbumCodeKey,
            [_albumCode, eventCode, _studioCode, selectedPath.value]);
        List<String> codes = prefs.getStringList(eventCodeAlbumCodeKey) ?? [];
        showLog(
            'codes codes in $codes  $album detail $_albumCode $eventCode, $_studioCode, $path}');
      }

      isLoading = false;
      setBusy(false);
      //await updateAlbum();
      }catch(e,s){
      showLog("album detail $e, $s");
      ToastUtil.getToast(context, e.toString(),s.toString());
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> updateStatus() async {
    try {
      List<OrderImage> res =
          await orderModelDao.imagesWhereUploadedAndAlbumCode(_albumCode);
      showLog("status.updateStatus $_albumCode ${res.length}");
      if (res.isNotEmpty) {
        status = res.length;
        showLog("status.value res  $status");
        notifyListeners();
        return res.length;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
  Stream<String> streamProgress() async* {
    Stream<List<OrderImage>> uploadedImages =
    orderModelDao.streamImageNamesWhereUploadedAndAlbumCode(_albumCode);
    List<OrderImage> images = orderModelDao.getImagesWhereAlbumCode(_albumCode);
    imagesCount = images.length.toString();
    await for (List<OrderImage> progress in uploadedImages) {
      //int total = images.value.length;
      int current = progress.length;

      if (current >= int.parse(imagesCount)) {
        yield 'done';
        break;
      }

      yield '$current/$imagesCount'; // e.g., "3/10"
    }
  }


  Stream<String> streamCompressionProgress() async* {
    Stream<List<OrderImage>> imagesRows =
    orderModelDao.streamImagesWhereCompressedAndAlbumCode(_albumCode);
    List<OrderImage> images = orderModelDao.getImagesWhereAlbumCode(_albumCode);
    imagesCount = images.length.toString();
    await for (List<OrderImage> progress in imagesRows) {
      //int totalImageCount = images.value.length;
      int current = progress.length;

      showLog('Compression progress: $current of $imagesCount');

      if (current >= int.parse(imagesCount)) {
        yield 'done';
        break;
      }

      yield '$current/$imagesCount'; // emit raw numbers
    }
  }


  Stream<List<OrderImage>> streamImageForView() async* {
    Stream<List<OrderImage>> imagesRows =
        orderModelDao.streamImagesWhereAlbumCode(_albumCode);
    await for (List<OrderImage> images in imagesRows) {
      showLog("Original list length: ${images.length}");
      if (Platform.isAndroid) {
        yield images;
      } else {
        final filteredImages = images
            /*.where((image) => image.uploaded != false)
            .toList()*/
            ;
        showLog("Filtered list length: ${filteredImages.length}");

        yield filteredImages;
      }
      //yield images;
    }
  }

  periodicTask(String directoryPath) async {
    compressedEvents.remove(localEventCode);

    /* if (streamingAlbums.contains(_albumCode)) {
      showLog("Already running $streamingAlbums ");
      return;
    } else {
      showLog("first time running ");
      streamingAlbums.add(_albumCode);
    }*/

    Timer.periodic(localDirectoryListenTime, (Timer timer) async {
        showLog("periodic compressedEvents $compressedEvents");
      ImageFileUploader imageFileUploader = ImageFileUploader();
      await imageFileUploader.updateUploadStatus(
          localEventCode, albumCode, albumName ?? '');
      pendingImagesForUpload?.clear();
      pendingImagesForUpload = await orderModelDao
       .getImagesWhereEventCodeWhereNotUploaded();
      if (pendingImagesForUpload!.isNotEmpty) {
        showLog("periodic pendingImagesForUpload $pendingImagesForUpload");

         uploadImagesInThisFolder(localEventCode, albumCode,isFromStreaming: true);

      }
      bool isDirectoryModified = await listenToDirectory(directoryPath);

      if (isDirectoryModified) {
        timer.cancel();
        compressedEvents.remove(localEventCode);
        showLog('if periodicTask isDirectoryModified : $isDirectoryModified');
        compressImagesInThisFolder(localEventCode);
        notifyListeners();
      } else {
        showLog(
            'else periodicTask isDirectoryModified $directoryPath : $isDirectoryModified');
      }

      // await uploadSingleImageInThisFolder(_eventCode);
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
      showLog('periodicTask directoryPath');
    });
  }

  StreamSubscription? directorySubscription;

  Future<bool> listenToDirectory(String directoryPath) async {
    // Create a Directory object for the path
    final directory = Directory(directoryPath);
    showLog('listenToDirectory $directory');
    // Check if the directory exists
    if (!directory.existsSync()) {
      showLog("Directory does not exist.$directory");
      isDirectoryExist.value =false;
      notifyListeners();
      return false;
    }else{
      isDirectoryExist.value =true;
      notifyListeners();
    }
    bool isDirectoryModified = await processDirectory(directoryPath);
    return isDirectoryModified;
  }

  Future<bool> processDirectory(String directoryPath) async {
    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: 'photomall');
    try {
      // Fetch album data from the database
      Album? album = await albumModelDao.getAlbumWhereCode(_albumCode);
      showLog('getAlbumWhereCode $album');

      // Get the last modification time from the database
      DateTime? directoryModifiedTimeInDb =
          DateTime.tryParse(album?.directoryModifiedTime ?? "");
      var dir = Directory(directoryPath);

      showLog(
          "Last recorded directoryModifiedTime: $directoryModifiedTimeInDb");
      if (dir.existsSync()) {
        var modifiedTime = dir.statSync().modified;
        showLog("Last modified time: $modifiedTime");
        if (directoryModifiedTimeInDb != null &&
            modifiedTime.isAfter(directoryModifiedTimeInDb)) {
          showLog("Directory is modified");
          await albumModelDao.updateModifiedTimeWhereAlbumCode(
              albumCode: _albumCode,
              modifiedTime: modifiedTime.toIso8601String());
          showLog("Updated last modified time in DB: $modifiedTime");
        } else {
          showLog("Directory is Unmodified or no change");
          await albumModelDao.updateModifiedTimeWhereAlbumCode(
              albumCode: _albumCode,
              modifiedTime: modifiedTime.toIso8601String());
          showLog("Updated last modified time in DB: $modifiedTime");
          return false;
        }
      } else {
        showLog("Directory does not exist");
      }
      // Fetch existing image names from the database
      List<String> existingImageNames = [];
      List<OrderImage>? localOrders =
          await orderModelDao.getImagesWhereAlbumCode(_albumCode);
      if (localOrders != null) {
        existingImageNames = localOrders.map((order) => order.name!).toList();
      }
      showLog('Existing images in database: $existingImageNames');
      // Prepare a list to store new orders
      List<OrderImage> newOrders = [];
      DateTime latestFileModifiedTime =
          directoryModifiedTimeInDb ?? DateTime(2000);

      // Asynchronously list files and process them
      await for (var file in Directory(directoryPath)
          .list(recursive: false, followLinks: false)) {
        if (file is File) {
          String fileName = pathq.basename(file.path);
          // Skip hidden or trashed files
          if (fileName.startsWith('.') || fileName.startsWith('.trashed-')) {
            showLog("Skipping hidden or trashed file: $fileName");
            continue;
          }
          String? extension = lookupMimeType(file.path)?.split('/').last;

          DateTime fileModifiedTime =
              await file.stat().then((stat) => stat.modified);

          // Check if the file is newly added or modified
          if (!existingImageNames.contains(fileName) ||
              (directoryModifiedTimeInDb != null &&
                  fileModifiedTime.isAfter(directoryModifiedTimeInDb))) {
            showLog("localOrders.first.eventCode: ${localOrders.first.eventCode}");
            final newOrder = OrderImage(
                uploadStatus: 0,
                code: null,
                path: file.path,
                name: fileName,
                eventCode: localOrders.first.eventCode,
                uploaded: false,
                albumCode: _albumCode,
                compressionStatus: 0,
                screenDisplay2ImageUrl: service.generateUniqueId(),
                sha256: service.generateUniqueId());
            if ((extension == 'jpeg' || extension == 'jpg')) {
              newOrders.add(newOrder);
              showLog("New or modified file detected: $fileName");
            } else {
              showLog("file format not supported: $fileName");
              try {
                orderModelDao.deleteOrderWherePath(file.path);
                showLog("deleteOrderWherePath ${file.path}");
              } catch (e) {
                showLog(e);
              }
            }
          } else {
            showLog("Skipping unchanged file: $fileName");
          }

          // Update latest modified time
          if (fileModifiedTime.isAfter(latestFileModifiedTime)) {
            latestFileModifiedTime = fileModifiedTime;
          }
        } else {
          showLog("Skipping non-file entity: ${file.path}");
        }
      }

      // Insert new files into the database
      if (newOrders.isNotEmpty) {
        await orderModelDao.insertAllOrders(newOrders);
        showLog("Inserted ${newOrders.length} new orders into the database.");
        return true;
      } else {
        showLog("No new or modified files to insert.");
        return false;
      }
    } catch (e, stackTrace) {
      // Handle any errors
      showLog("Error while processing directory: $e");
      showLog("StackTrace: $stackTrace");
      return false;
    }
  }

  void stopListeningToDirectory() {
    // Cancel the listener if it's active
    directorySubscription?.cancel();
    showLog("Directory listener stopped.");
  }

  void addPhotosToList() {
    int previousLength = localImages.value.length;
    int counter = 0;
    if (images.value != null) {
      for (OrderImage? photos in images.value) {
        if (counter == 5) {
          break;
        }
        if (!localImages.value.contains(photos)) {
          showLog("add images $counter");
          localImages.value.add(photos!);
          counter++;
        }
      }
      if (previousLength < localImages.value.length) {
        showLog("more image added..");
        setBusy(false);
      }
    }
  }

  listenAlbumImages() async {
    String path = "";
    List<OrderImage>? imagesRows =
        await orderModelDao.getImagesWhereAlbumCode(_albumCode);
    showLog("image value listening");
    if (imagesRows != null && imagesRows.isNotEmpty) {
      for (OrderImage image in imagesRows) {
        final entity = FileSystemEntity.typeSync(image.path ?? '');
        showLog("value loop \n ${entity == FileSystemEntityType.directory}");

        if (!images.value.contains(image) &&
            entity != FileSystemEntityType.directory) {
          showLog("value listening added ${image.name} ");
          bool status = checkAlreadyExist(image.name!);
          if (status) {
            images.value.removeWhere((element) => element.name == image.name);
          }

          path = image.path!;

          images.value.add(OrderImage(
              albumCode: _albumCode,
              uploaded: image.uploaded,
              name: image.name,
              path: path,
              code: image.name,
              id: image.id));
          setBusy(false);
        }
      }
    }
    showLog("50 sec start..");
  }

  bool checkAlreadyExist(String name) {
    bool status = false;
    for (var element in images.value) {
      if (element.name == name) {
        status = true;
      }
    }
    return status;
  }

  Future<void> getAlbum() async {
    final albumModelDao = objectBox.albumModelDao;
    Album? album = await albumModelDao.getAlbumWhereCode(_albumCode);
    routePath = album!.path;
    albumName = album.name;
  }

  Future<void> uploadImagesInThisFolder(String eventCode,String albumCode,
      {bool isFromStreaming = false}) async {
    if (streamingAlbums.contains(eventCode)) {
      showLog("Already running $streamingAlbums ");
      return;
    } else {
      showLog("first time running");
      streamingAlbums.add(eventCode);
    }
   while(true) {
      showLog("uploadImagesInThisFolder running in while");
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate)
          : null;
      // String path = '';
      // List<OrderImage>? uploadedImages =
      //     orderModelDao.getImagesWhereAlbumCode(albumCode);
      //
      // if (uploadedImages.isNotEmpty) {
      //   path = pathq.dirname(uploadedImages.first.path!);
      // }
      imagesUpload =
          await orderModelDao.getImagesWhereEventCodeWhereNotUploaded() ?? [];
      showLog('imagesUploadimagesUpload ${imagesUpload?.length}');

      List<OrderImage>? totalFiles =
          await orderModelDao.getImagesWhereEventCodeWhereUploaded(eventCode);
      showLog('totalFiles ${totalFiles?.length}');
      if (totalFiles != null) {
       // imagesCount.value = totalFiles.length.toString();
      }
      if (imagesUpload.isNotEmpty) {
        //path = pathq.dirname(imagesUpload.first.path!);
        // showLog("dirname $path");
      }
      if (imagesUpload.isEmpty && !isFromStreaming) {
        uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: albumName!, uploadingName: '', remainingFileCount: 0);
      }
      if (imagesUpload.isNotEmpty) {
        int batchSize = 3; //await deviceUtil
        //.calculateBatchSize(); // Batch size for processing images

        List<Future<void>> uploadFutures = [];
        // Process images in batches
        while (imagesUpload.isNotEmpty) {
          //for (int i = 0; i < imagesUpload.length; i += batchSize) {
          //List<OrderImage> batchImages = imagesUpload.sublist(
          // i,
          // i + batchSize < imagesUpload.length
          //    ? i + batchSize
          //   : imagesUpload.length);
          UploadState? uploadStatus =
              await uploadStatusDao.getUploadStateWhereAlbumName(eventCode!);
          if (/*uploadStatus == null && */ !isFromStreaming && false) {
            uploadStatusDao.deleteUploadStatus();
            var event = await eventModelDao.getEventWhereCode(eventCode);
            List<OrderImage> imagesUploadCount = await orderModelDao
                .getImagesCountWhereEventCodeWhereNotUploaded(eventCode);
            showLog('imagesUploadCount ${imagesUploadCount.length} ');

            uploadStatusEntity.add(UploadState(
                eventName: event?.name,
                totalFilesCount: totalFiles.length,
                albumName: albumName!,
                remainingFilesCount: imagesUploadCount.length,
                uploadComplete: false));
            await uploadStatusDao.insertUploadStatus(uploadStatusEntity);
          }
          album = await albumModelDao.getAlbumWhereCode(_albumCode);

          if (album?.uploadStatus != null && album?.uploadStatus != 1) {
            showLog('uploadStopped ${album?.uploadStatus} ');
            uploadState.value = false;
            Platform.isWindows
                ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
                : null;
            return;
          }
          // Process each image in the batch concurrently
          for (OrderImage image in imagesUpload) {
            Platform.isWindows
                ? WindowsTaskbar.setProgressMode(
                    TaskbarProgressMode.indeterminate)
                : null;
            // uploadFutures.add(_processImage(image));

            uploadFutures.add(uploadImageToSpacesFromCache(
              image: image
            ));
            controller.startProcessing();
            controller.progress.value = image.name!;
            List<OrderImage>? remainingFileCount = await orderModelDao
                .getImagesCountWhereEventCodeWhereNotUploaded(eventCode);
            if (!isFromStreaming && false) {
              uploadStatusDao.updateUploadStateWhereAlbumName(
                  albumName: albumName!,
                  uploadingName: image.name! ?? '',
                  remainingFileCount: remainingFileCount!.length);
            }
          }

          // Wait for all images in the batch to be processed
          await Future.wait(uploadFutures);
          showLog("images length is ${imagesUpload?.length}");
          // batchImages.clear();
          uploadFutures.clear();
          imageCache.clear();
          //batchSize = 3; //await deviceUtil.calculateBatchSize();
          imagesUpload.clear();
          imagesUpload =
              await orderModelDao.getImagesWhereEventCodeWhereNotUploaded() ??
                  [];
          showLog('uploadFutures length is  ${uploadFutures.length}');
        }
      }
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
      //showLog('uploadFutures length is  ${uploadFutures.length}');

      UploadState? uploadStatus =
          uploadStatusDao.getUploadStateWhereAlbumName(albumName!);
      if (uploadStatus != null && !isFromStreaming) {
        uploadStatusDao.updateUploadStateWhereAlbumName(
            albumName: albumName!, uploadingName: '', remainingFileCount: 0);
      }
      // Fetch the next batch of images
      //if (!Platform.isAndroid) {
      await Future.delayed(const Duration(seconds:30));

    }

// }
  }

  Future<void> compressImagesInThisFolder(String eventCode) async {
    try{
      List<OrderImage> images = orderModelDao.getImagesWhereAlbumCode(_albumCode);
      imagesCount = images.length.toString();
      showLog("Starting compression for eventCode: $eventCode");
      if (compressedEvents.contains(eventCode)) {
        showLog("Already compressing $compressedEvents ");
        return;
      } else {
        showLog("first time compressing");
        compressedEvents.add(eventCode);
      }
      List<OrderImage>? imagesToCompress =
          await orderModelDao.getImagesWhereEventCodeWhereNotCompress();

      if (imagesToCompress.isEmpty) {
        await periodicTask(streamingPath);

        showLog("No images to compress for $eventCode");
        return;
      }

      List<Future<void>> compressFutures = [];

      while (imagesToCompress!.isNotEmpty) {
        showLog("Remaining images to compress: ${imagesToCompress.length}");

        for (OrderImage image in imagesToCompress) {
          compressFutures.add(compressAndSave(
            image,
          ));
        }

        await Future.wait(compressFutures);

        compressFutures.clear();

        // Refresh list after processing current batch
        imagesToCompress =
            await orderModelDao.getImagesWhereEventCodeWhereNotCompress();

      }
      await periodicTask(streamingPath);
      showLog("Compression completed for eventCode: $eventCode");
    }catch(e){
      showLog("compressImagesInThisFolder $e");
      compressedEvents.remove(eventCode);
    }
  }

  Future<File?> compressAndSave(OrderImage image, {int quality = 50}) async {
    showLog("compressAndSave init ${image.id}");
    final String path = image.path ?? '$routePath/${image.name}';

    String? extension = pathq.extension(path).replaceFirst('.', '');
    if (extension.isEmpty) {
      extension = lookupMimeType(path)?.split('/').last ?? '';
    }
    String? lowerCaseExtension = extension.toLowerCase();
    if (lowerCaseExtension != 'jpeg' && lowerCaseExtension != 'jpg') {
      showLog("Unsupported file type for compression: $path");
      orderModelDao.deleteOrderWherePath(path);
      return null;
    }

    studioSize = await fileUtil.getStudioSize(eventScreenDisplay);
    showLog("getStudioSize albums ${studioSize.height} x ${studioSize.width}");

    Compression? compression;

    try {
      if (Platform.isAndroid) {
        compression = await imageCompressionInIsolate.compressTheFile({
          'file': File(path),
          'height': studioSize.height,
          'width': studioSize.width,
        });
      } else {
        compression = await compute(imageCompressionInIsolate.compressTheFile, {
          'file': File(path),
          'height': studioSize.height,
          'width': studioSize.width,
        });
      }
      showLog("compressAndSave-compression ${compression?.uint8list?.length}");
      if (compression?.uint8list == null) {
        showLog("Compression failed");
        orderModelDao.updateImageCompressionStatus(4, image.id, "0");
        return null;
      }

      final Uint8List? uint8list = compression?.uint8list;
      final String? ratio = compression?.ratio;

      final dir = await getApplicationCacheDirectory();
      final baseName = pathq.basenameWithoutExtension(path);
      final ext = pathq.extension(path);
      final albumFolder = pathq.join(dir.path, image.albumCode ?? '');
      final fileName = '$baseName$ext';
      final compressedPath = pathq.join(albumFolder, fileName);
      showLog("compressedPath $compressedPath");
      final compressedFile = File(compressedPath);
      if (uint8list != null) {
        final folder = Directory(albumFolder);
        if (!await folder.exists()) {
          await folder.create(recursive: true);
        }
        await compressedFile.writeAsBytes(uint8list);
        //orderModelDao.updateImageBytes(image.id, uint8list, ratio);
        orderModelDao.updateImageCompressionStatus(
          1,
          image.id,
          ratio ?? "1",
        );
      }

      return compressedFile;
    } catch (e, s) {
      showLog("Error compressing image: $e\n$s");
      if (e.toString().contains("PathNotFoundException")) {
       // orderModelDao.deleteOrderWherePath(path);
        ToastUtil.getToast(context, "Couldn't load the image. It may have been moved or deleted.",'${path}',);
       await  Future.delayed(const Duration(seconds: 15));

      }
      return null;
    }
  }

  Future<bool> uploadImageToSpacesFromCache({
    required OrderImage image,

  }) async {
    final dir = await getApplicationCacheDirectory();
    String cacheFolder = pathq.join(dir.path, image.albumCode);
    final String uniqueImageName = image.sha256!;
    final String path = image.path ?? '$routePath/${image.name}';

    final extension = pathq.extension(path);
    final String cachedPath = pathq.join(
      cacheFolder,
      '${pathq.basenameWithoutExtension(image.path!)}$extension',
    );

    final File cachedFile = File(cachedPath);

    if (!cachedFile.existsSync()) {
      showLog("Cached file not found: $cachedPath");
      return false;
    }

    final Uint8List uint8list = await cachedFile.readAsBytes();

    final DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: pmFilePath ?? "photomall");

    final DateTime uploadStartTime = DateTime.now();
showLog("image.eventCode localEventCode ${image.eventCode},,,, $localEventCode");
    final UploadFileResponse uploadFileResponse = await service.uploadFile(
      path: cachedPath,
      bytes: uint8list,
      objectKey: uniqueImageName,
      extension: extension,
      eventCode: image.eventCode!='' ?image.eventCode!:localEventCode,
      ableCode: image.albumCode,
      ableType: "albums",
      ratio: image.ratio ?? "1.5",
      isFromCompressForScreenDisplay2: eventScreenDisplay == 2,
    );

    if (uploadFileResponse.hash == "Already Uploaded") {
      showLog("Already uploaded: ${image.path}");
      orderModelDao.updateImageUploadedStatusTrue(image.id, 2,
          code: '', path: image.path!);
      return true;
    }

    if (uploadFileResponse.hash.isEmpty ||
        uploadFileResponse.preSignedURlCode.isEmpty) {
      showLog("Upload failed: invalid response");
      return false;
    }

    final ImageSize size = await service.getImageDimensions(uint8list);

    final ImageUploadResponse? imageUploadResponse =
        await apiRepo?.imageUploadApiCall(
      type: 'albums',
      ableCode:image.albumCode??_albumCode,
      filePath: pmFilePath!,
      studioCode: _studioCode,
      jvtFileName: uniqueImageName,
      fileName: pathq.basename(image.path!),
      imageHash: uploadFileResponse.hash,
      eventCode: image.eventCode??localEventCode,
      extension: extension.replaceAll(".", '').toLowerCase(),
      preSignedUrlCode: uploadFileResponse.preSignedURlCode,
      screenDisplay: eventScreenDisplay.toString(),
      imageWidth: size.width.toString(),
      imageHeight: size.height.toString(),
      ratio: image.ratio ?? "1",
    );

    if (imageUploadResponse?.file == null) {
      showLog("ImageUploadResponse is null");
      DeviceUtil().callChatNotifier(
        'imageUploadResponse error',
        'imageUploadResponse is null in event: $localEventCode',
      );
      Platform.isWindows
          ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
          : null;
      await Future.delayed(const Duration(seconds: 5));
      return false;
    }

    final int uploadTimeSeconds =
        DateTime.now().difference(uploadStartTime).inSeconds.clamp(1, 999999);
    final double uploadSpeed = (uint8list.length / 1024) / uploadTimeSeconds;

    controller.uploadSpeed.value = uploadSpeed;
    showLog('Upload speed: ${uploadSpeed.toStringAsFixed(2)} KB/s');

    orderModelDao.updateImageUploadedStatusTrue(
      image.id,
      2,
      code: imageUploadResponse!.file!.code!,
      path: image.path!,
    );

    return true;
  }



  updateAlbum() async {
    int lastUpdatedAt = 0;

    Album? album = await albumModelDao.getAlbumWhereCode(_albumCode);
    if (album != null) {
      lastUpdatedAt = album.orderLastUpdatedAt ?? 0;
    }
    OrderController orderController = OrderController();
    AlbumShowResponse? albumShowResponse = await apiRepo!.albumShowApiCall(
        studioCode: _studioCode,
        albumCode: _albumCode,
        lastUpdatedAt: lastUpdatedAt);
    if (albumShowResponse != null) {
      await orderController.upsertOrder(
        albumCode: _albumCode,
        eventCode: localEventCode,
        albumShowResponse: albumShowResponse,
      );
    }
  }
}

