import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as pathq;

import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/api/apiRequestModels/digital_oceans_space_service.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/add_album_response_model.dart'
    as response;
import 'package:photomall_studio_manager/api/apiResponseModels/album_index_response.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/controllers/album_controller.dart';
import 'package:photomall_studio_manager/controllers/local_directory_controller.dart';
import 'package:photomall_studio_manager/database/dao/album_dao.dart';
import 'package:photomall_studio_manager/main.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/device_util.dart';
import 'package:photomall_studio_manager/utils/file_utils.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import '../../database/object_box_model/object_box_models.dart';
import '../../image_uploader/image_file_uploader.dart';

class AlbumListController extends BaseObserver {
  bool isLoading = false;
  bool isAlertDialog = false;
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;
  String _eventCode = '';

  String get eventCode => _eventCode;
  String _studioCode = '';
  String deviceId = '';
  final albumModelDao = objectBox.albumModelDao;

  final orderModelDao = objectBox.orderModelDao;
  DeviceUtil deviceUtil = DeviceUtil();
  List<Album>? albums = [];
  List<String>? albumCode = [];
  FileUtil fileUtil = FileUtil();
  LocalDirectoryController localDirectoryController =
      LocalDirectoryController();
  bool isListeningStop = false;
  List<UploadModel>? images = [];
  List thumbNail = [];

  AlbumListController({
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Future<void> getInitialValues(
    String eventCode,
    String studioCode,
  ) async {

    try {
      //bool isIsolate =
      //   preferences.getBool(isIsolateRunningPreferenceKey) ?? false;
      showLog("isIsolate running $isIsolate");
      if (isIsolate == false) {
        showLog("start running isolate");
        // await preferences.setBool(isIsolateRunningPreferenceKey, true);
        isIsolate = true;
        //ImageFileUploader imageFileUploader = ImageFileUploader();
        //imageFileUploader.runInIsolates(eventCode);
      } else {
        showLog("running isolate");
      }
    } catch (e) {
      showLog(e);
    }

    isLoading = true;
    setBusy(false);
    deviceId = await PreferenceHelper.getString(deviceIdPreferenceKey);
    _eventCode = eventCode;
    _studioCode = studioCode;

    showLog('updateAlbumIndex');
    await updateAlbumIndex();
    await getAlbums();

    //await orderModelDao.getImagesWhereAlbumCodeForThumbNail();
    // listen();
    // TODO: implement
    isLoading = false;
    setBusy(false);
  }

  Future<void> checkSubFolderAndCreateAlbum(
      String albumPath, BuildContext context) async {
    List<FileSystemEntity> files = Directory("$albumPath/").listSync();

    for (FileSystemEntity file in files) {
      if (file is Directory) {
        // If it's a directory, print a log and skip it
        showLog('${file.path} is Directory');
        String albumName = path.basename(file.path);
        await addAlbum(albumName, file.path, context);

        showLog("checkSubFolderAndCreateAlbum Directory: $file");
      } else {
        showLog("checkSubFolderAndCreateAlbum file: $file");

        // If it's a file, add it to the filtered list
      }
    }
  }

  Future<String?> addAlbum(
      String name, String path, BuildContext context) async {
    String? albumCode;
    try {
      isLoading = true;
      setBusy(false);
      // call api to store album
      response.AddAlbumResponse? addAlbumResponse =
          await apiRepo!.albumStoreApiCall(
        eventCode: _eventCode,
        path: path,
        studioCode: _studioCode,
        albumName: name,
        albumType: 5,
      );
      if (addAlbumResponse != null) {
        albumCode = addAlbumResponse.album!.code!;
        String directoryPath = path;
        Directory directory = Directory(directoryPath);
        DateTime directoryModifiedTime = directory.statSync().modified;
        showLog('directoryModifiedTime is $directoryModifiedTime');

        // insert album
        await albumModelDao.insertAllAlbum([
          Album(
              orderLastUpdatedAt: 0,
              code: albumCode,
              eventCode: _eventCode,
              name: addAlbumResponse.album!.name!,
              path: path,
              uploadStatus: 1,
              lastUpdatedAt: addAlbumResponse.album!.lastUpdatedAt!,
              type: addAlbumResponse.album!.albumType!,
              size: addAlbumResponse.album!.albumSize!.size,
              deviceId: deviceId,
              filesCount: 0,
              imagesCount: 0,
              directoryModifiedTime: directoryModifiedTime.toIso8601String())
        ]);

        // insert images
        await insertPhotos(path, albumCode, _eventCode);
        //await checkSubFolderAndCreateAlbum(path, context);
      }

      isLoading = false;
      setBusy(false);
      return albumCode;
    } catch (e) {
      isLoading = false;
      setBusy(false);
      ToastUtil.getToast(context, "Album", "Not added");
      showLog("[Error] :: addAlbum \n $e");
    }
    return null;
  }

  /* Future<void> insertPhotos(
      String path, String albumCode, String eventCode) async {
    showLog("step 1");
    FileUtil fileUtil = FileUtil();
    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: "photomall");
    String directory = path;
    List<FileSystemEntity> images = [];
    List<FileSystemEntity> files = Directory("$directory/").listSync();
    for (var file in files) {
      bool isDirectory = FileSystemEntity.isDirectorySync(file.path);
      String? extension = fileUtil.getExtension(file);
      showLog("getExtension  $extension");

      if ((extension == 'jpeg' || extension == 'jpg') && !isDirectory) {
        showLog("DigitalOceanSpacesService extension $extension");
        images.add(file);
      }
    }
    images.sort((a, b) => a.path
        .split('/')
        .last
        .toLowerCase()
        .compareTo(b.path.split('/').last.toLowerCase()));

    showLog("step 2");
    int batchSize = 100;
    int imageCount = images.length;
    if (images.isNotEmpty) {

      List<appDb.OrdersCompanion> orders = [];
      {
        for (var element in files) {
          bool isDirectory = FileSystemEntity.isDirectorySync(element.path);
          String? extension = fileUtil.getExtension(element);
          if ((extension == 'jpeg' || extension == 'jpg') && !isDirectory) {
            orders.add(appDb.OrdersCompanion(
                code: const drift.Value(null),
                eventCode: drift.Value(eventCode),
                path: drift.Value(element.path),
                name: drift.Value(element.path.split('/').last),
                uploaded: const drift.Value(false),
                sha256: drift.Value(service.generateUniqueId()),
                albumCode: drift.Value(albumCode)));
          } else {
            showLog("extension is $extension and path is ${element.path}");
          }
        }

        await orderModelDao.insertAllOrders(orders);
        await albumModelDao.updateFilesCountWhereAlbumCode(
            code: albumCode, filesCount: files.length);
      }

    }
  }
*/
  Future<void> insertPhotos(
      String path, String albumCode, String eventCode) async {
    showLog("New step 1 insertPhotos");
    FileUtil fileUtil = FileUtil();
    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: "photomall");
    List<FileSystemEntity> imageFiles = [];
    await for (FileSystemEntity file in Directory(path).list()) {
      bool isDirectory = await FileSystemEntity.isDirectory(file.path);
      String? extension = fileUtil.getExtension(file)?.toLowerCase();
      showLog("insertPhotos :${file}");
      String fileName = pathq.basename(file.path);

      // Skip if:
      // 1. It's a directory
      // 2. Extension is not jpeg or jpg
      // 3. Hidden or trashed file
      if (isDirectory ||
          !(extension == 'jpeg' || extension == 'jpg') ||
          fileName.startsWith('.') || fileName.startsWith('.trashed-')) {
        continue;
      }

      // Additional check: try opening the file to make sure it's readable
      try {
        await File(file.path).open(); // test access
        imageFiles.add(file);
      } catch (e) {
        showLog("Skipping unreadable file: $fileName, reason: $e");
        continue;
      }
    }
    // Sort image files by name
    imageFiles.sort((a, b) => a.path
        .split('/')
        .last
        .toLowerCase()
        .compareTo(b.path.split('/').last.toLowerCase()));

    showLog("step 2");

    if (imageFiles.isNotEmpty) {
      List<OrderImage> orders = [];

      for (var file in imageFiles) {
        showLog("album list insertPhotos OrderImage eventCode :$eventCode");

        orders.add(OrderImage(
          uploadStatus: 0,

          screenDisplay2ImageUrl: service.generateUniqueId(),
          code: null,
          eventCode: eventCode,
          path: file.path,
          name: pathq.basename(file.path),
          uploaded: false,
          sha256: service.generateUniqueId(),
          albumCode: albumCode,
          compressionStatus: 0,
        ));
      }


      await orderModelDao.insertAllOrders(orders);
      await albumModelDao.updateFilesCountWhereAlbumCode(
        code: albumCode,
        filesCount: imageFiles.length,
      );
    }
  }

  getAlbums() async {
    if (albums != null) {
      albums!.clear();
    }

    albums = await albumModelDao.getAlbumWhereEventCode(_eventCode);
    try {
      if (albums != null && albums!.isNotEmpty) {
        for (int i = 0; i < albums!.length; i++) {
          albumCode!.add(albums![i].code);
        }
        showLog(
            'error in getting${albumCode!.length} albumCode${thumbNail.length}');
        if (thumbNail.length != albumCode!.length) {
          int difference = albumCode!.length - thumbNail.length;

          showLog('length not match $difference');
          for (int i = 0; i < difference; i++) {
            thumbNail.add(
                'https://cdn.photomall.in/photomall/b0d2e23b-3d4d-4ded-8576-963356e4d1098KJmmHBt');
          }
        }
      }
    } catch (e) {
      showLog('error in getting albumCode');
    }
  }

  Future<void> updateAlbumIndex() async {
    AlbumIndexResponse? albums = await apiRepo!
        .albumIndexApiCall(studioCode: _studioCode, eventCode: _eventCode);
    if (albums != null) {
      showLog("updateAlbumIndex ${albums.medias}");

      AlbumController albumController = AlbumController();
      await albumController.upsertAlbum(eventCode: _eventCode, albums: albums);
      try {
        for (int i = 0; i < albums.medias!.length; i++) {
          for (int j = 0;
              j < albums.medias![i].mediable!.jvtFileConnectors!.length;
              j++) {
            thumbNail.add(
                'https://cdn.photomall.in/photomall/${albums.medias![i].mediable!.jvtFileConnectors![j].jvtFile!.name}');
          }
        }
      } catch (e) {
        showLog('error in thumbnail $e');
      }
    }
  }

  upsertImages(List<String> dbImages, List<String> newImages, String albumCode,
      List<FileSystemEntity> files) async {
    DigitalOceanSpacesService service =
        DigitalOceanSpacesService(originalFilePath: "photomall");
    localDirectoryController.upsertLocalImages(
      dbImages,
      newImages,
      (String s, List<String>? list) async {
        if (s == createImage) {
          List<OrderImage> orderImages = [];

          for (String data in list!) {
            if (isListeningStop) {
              return;
            }
            final entity = FileSystemEntity.typeSync(files
                    .where((element) => element.path.split('/').last == data)
                    .first
                    .path);

            showLog(
                "upsertImages ===> ${entity == FileSystemEntityType.directory}");
            showLog(
                "value loop \n ${entity == FileSystemEntityType.directory}");

            if (entity != FileSystemEntityType.directory) {
              orderImages.add(OrderImage(
                uploadStatus: 0,

                albumCode: albumCode,
                eventCode: _eventCode,
                path: files
                    .where((element) => element.path.split('/').last == data)
                    .first
                    .path,
                name: data.split('/').last,
                code: null,
                uploaded: false,
                sha256: service.generateUniqueId(),
                compressionStatus: 0,
                // api
              ));
            }
          }
          if (orderImages.isNotEmpty) {
            await orderModelDao.insertAllOrders(orderImages);
          }
          // await uploadImagesInThisEvent();
        }
        if (s == updateImage) {
          showLog("update images ..");
          //  await uploadImagesInThisEvent();
        }
      },
    );
  }

/*
  uploadImagesInThisEvent() async {
    String path = '';
    images = await albumModelDao.getEventImagesForUpload(_eventCode);
    showLog("the length wher ${images?.length}");
    while (images!.isNotEmpty) {
      if (images != null) {
        for (UploadModel image in images!) {
          if (isListeningStop) {
            return;
          }
          showLog("the processing id ${image.order!.id}");
          if (image.order?.path != null && image.order!.path!.isNotEmpty) {
            path = image.order!.path!;
          } else {
            path = '${image.album!.path}/${image.order!.name}';
          }
          EventModelDao eventModelDao = EventModelDao();
          var events = await eventModelDao.getEventWhereCode(_eventCode);
          showLog(' screen size ${events?.screenDisplay}');
          Uint8List? uInt8list =
              await fileUtil.compressTheFile(File(path), events!.screenDisplay);
          if (uInt8list != null) {
            String? extension = fileUtil.getExtension(File(path));

            String base64encodeIMage = base64Encode(uInt8list);
            ImageUploadResponse? imageUploadResponse = await apiRepo!
                .imageUploadApiCall(
                    type: 'albums',
                    ableCode: image.album!.code,
                    image: 'data:image/$extension;base64,$base64encodeIMage',
                    studioCode: _studioCode,
                    fileName: pathq.basename(path));
            showLog('imageUploadResponse start');

            if (imageUploadResponse != null &&
                (imageUploadResponse!.file!.code != null)) {
              showLog(
                  'imageUploadResponse inProgress ${imageUploadResponse!.file!.code!}');

              await orderModelDao.updateImageUploadedStatusTrue(
                  image.order!.id, imageUploadResponse!.file!.code!, path);
            } else {
              showLog('imageUploadResponse is returned');
            }
          }
          // update images data uploaded in db
        }
      }
      images = await albumModelDao.getEventImagesForUpload(_eventCode);
    }
  }*/

/* void listen() {
    Timer.periodic(localDirectoryListenTime, (Timer timer) async {
      showLog("triggered listening ...");
      if (isListeningStop) {
        timer.cancel();
      } else {
        await listenAlbum();
      }
    });
  }*/
}
