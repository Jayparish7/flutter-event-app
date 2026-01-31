import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/transporter_response_model.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/image_util.dart';

import '../database/object_box_model/object_box_models.dart';
import '../main.dart';
import '../preference/preference_constants.dart';

class FileUtil {
  final orderModelDao = objectBox.orderModelDao;

  final folderModelDao = objectBox.folderModelDao;

  createFolder(
      String pathForFolder, String folderCode, String imagesPath) async {
    try {
      showLog("step 1 >  createFolder$folderCode $pathForFolder");
      Folder? rootFolder = await folderModelDao.getFolderWhereCode(folderCode);
      showLog(
          'FileUtil folderDetails $imagesPath custom${rootFolder?.customSegregationPath == imagesPath}');

      // Directory directory = await getApplicationDocumentsDirectory();
      String path = pathForFolder;
      if (rootFolder?.customSegregationPath != imagesPath) {
        String folderName = getNameForCustomSegregation(pathForFolder);
        String customPath =
            '${rootFolder?.customSegregationPath}/${rootFolder?.name}/$folderName';
        showLog('folderName $customPath');
        path = customPath;
      }
      Directory directory = Directory(path);
      showLog("step 00 >  createFolder ${await directory.exists()}");
      if (await directory.exists()) {
        return;
      } else {
        showLog("step 2 >  createFolder");
        Directory a = await directory.create(recursive: true);
        showLog("step 3 >  createFolder $a ");
        showLog("step 4 .,,.,>$path   createFolder ${a.path} ");
      }
    } catch (e) {
      showLog("createFolder ERROR : $e");
    }
  }

  String getNameForCustomSegregation(String pathForFolder) {
    String name = pathForFolder.split('/').last;
    switch (name) {
      case 'Selected':
        return 'Selected';

      case 'high':
        return 'Selected/high';
      case 'medium':
        return 'Selected/medium';
      case 'low':
        return 'Selected/low';
      case 'normal':
        return 'Selected/normal';
      default:
        return '';
    }
  }

  Uint8List? getImage(String path, BuildContext context) {
    final file = File(path);
    if (file.existsSync()) {
      return File(path).readAsBytesSync();
    } else {
      showLog('image missed');
      /* showMessage(
          context,
          'Selected image missed in your folder ---->'
              '$path',
          true);*/
    }
  }

  String? getMissedImage(String path, BuildContext context) {
    final file = File(path);
    if (file.existsSync()) {
      showLog('image checked');
      return null;
    } else {
      showLog('image missed');
      return path;
    }
  }

  void showMessage(BuildContext context, String message, bool? isErrorMessage) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: isErrorMessage == true ? Colors.red : Colors.green,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
      return;
    });
  }

  void writeTheimage(String path, Uint8List uint8list) {
    showLog('writeTheImage $path');
    try {
      File(path).writeAsBytesSync(uint8list);
      showLog("success write path \n $path ");
      showLog("File >> \n ${uint8list.length} ");
    } catch (e, s) {
      showLog("can't try to write $e ,$s");
    }
  }

  String? getExtension(FileSystemEntity file) {
    String? extension = lookupMimeType(file.path);
    if (extension != null) {
      return extension.split('/').last;
    } else {
      return null;
    }
  }

  Future<ImageSize> getStudioSize(int screenDisplay) async {
    String res = await PreferenceHelper.getString(screenDisplayKey);
    showLog("getStudioSize do screenDisplay $res");

    ScreenDisplay screenDisplayApi = ScreenDisplay.fromJson(jsonDecode(res));

    int data = (screenDisplay != null) ? screenDisplay : 4;
    showLog("getStudioSize do screenDisplay $res $data $screenDisplay");
    switch (data) {
      case 1:
        {
          return ImageSize(
            height: screenDisplayApi.screenDisplay1?.last ?? 135,
            width: screenDisplayApi.screenDisplay1?.first ?? 240,
          );
        }
        break;
      case 2:
        {
          showLog('dataScreenDisplay : $data');

          return ImageSize(
            height: screenDisplayApi.screenDisplay2?.last ?? 1080,
            width: screenDisplayApi.screenDisplay2?.first ?? 1920,
          );
        }
        break;
      case 3:
        {
          return ImageSize(
            height: screenDisplayApi.screenDisplay3?.last ?? 1440,
            width: screenDisplayApi.screenDisplay3?.first ?? 2560,
          );
        }
      case 4:
        {
          return ImageSize(
            height: screenDisplayApi.screenDisplay4?.last ?? 1440,
            width: screenDisplayApi.screenDisplay4?.first ?? 2560,
          );
        }
        break;
      default:
        {
          return ImageSize(
            height: 1440,
            width: 2560,
          );
        }
        break;
    }
  }

  Future<Uint8List?> compressFileForAndroid(
      File file, int width, int height) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: width,
      minHeight: height,
      quality: 100,
    );
    int? lengthInBytes = result?.lengthInBytes;

    // Convert to KB
    double? lengthInKB = lengthInBytes!.toDouble() / 1024;

    // Log the sizes
    showLog('compressFileForAndroid '
        'd $lengthInBytes bytes');
    showLog(
        'compressFileForAndroid File size: ${lengthInKB.toStringAsFixed(2)} KB');
    showLog(file.lengthSync());
    showLog(result?.length);
    return result;
  }

  Future<Uint8List?> compressTheFile(
      FileSystemEntity file, int? screenDisplay) async {
    // screen_display = 3
    //  img_width = 2560;
    //  img_height = 1440;
    double convertedHeight = 0;
    double convertedWidth = 0;

    ImageSize studioSize = await getStudioSize(screenDisplay!);
    showLog('file path ${file.path}');
    final entity = FileSystemEntity.typeSync(file.path ?? '');

    showLog("value loop path  ${entity == FileSystemEntityType.directory}");
    if (entity == FileSystemEntityType.directory) {
      orderModelDao.deleteOrderWherePath(file.path);
      showLog('file path ${file.path}...Directory is deleted');
    }
    Uint8List bytes = File(file.path).readAsBytesSync();
    String name = file.path.split('/').last;
    ImageSize? imageSize = ImageUtil.getHeightOfFirstImage(bytes);
    int ratio = (studioSize.width! > studioSize.height!)
        ? studioSize.width!
        : studioSize.height!;
    showLog("ratio is $ratio");
    if (imageSize != null) {
      if (imageSize.height! > imageSize.width!) {
        // is portrait
        if (imageSize.height! > studioSize.height!) {
          convertedHeight = studioSize.height!.toDouble();
          double deductionOfHeight = imageSize.height! / studioSize.height!;
          convertedWidth = double.parse(
              (imageSize.width! / deductionOfHeight).round().toString());
        }
      } else {
        // is landscape
        if (imageSize.width! > studioSize.width!) {
          convertedWidth = studioSize.width!.toDouble();
          double deductionOfWidth = imageSize.width! / studioSize.width!;
          convertedHeight =
              double.parse("${imageSize.height! / deductionOfWidth}");
        }
      }
      if (convertedHeight != 0 && convertedWidth != 0) {
        ImageUtil imageUtil = ImageUtil();
        Uint8List? byte = await imageUtil.compressImageForDesktop(
            file.path, convertedWidth.toInt(), convertedHeight.toInt());
        if (byte != null) {
          bytes = byte;
        }
      }
      // String path = '/home/nithinbabu/Documents/compressed/$name';
      // File(path).writeAsBytes(bytes);
      return bytes;
    }
    return null;
  }
}

class ImageCompressionInIsolate {
  Future<Compression?> compressTheFile(Map<String, dynamic> params) async {
    double convertedHeight = 0;
    double convertedWidth = 0;
    File file = params["file"];
    ImageSize studioSize =
        ImageSize(height: params["height"], width: params["width"]);
    showLog(
        'ImageCompressionInIsolatesss1s $studioSize  file path${studioSize.height} ${file.path}');
    final entity = FileSystemEntity.typeSync(file.path ?? '');
    showLog("value loop path  ${entity == FileSystemEntityType.directory}");
    if (entity == FileSystemEntityType.directory) {
    //  final orderModelDao = objectBox.orderModelDao;

     // orderModelDao.deleteOrderWherePath(file.path);
      showLog('file path ${file.path}...Directory is deleted');
    }
    Uint8List? bytes = File(file.path).readAsBytesSync();
    String name = file.path.split('/').last;
    String? ratio;
    ImageSize? imageSize = ImageUtil.getHeightOfFirstImage(bytes);
    showLog("calculateRatio $imageSize");

    if (imageSize != null) {
      showLog("calculateRatio1 ${imageSize.height}");

      if (imageSize.height! > imageSize.width!) {
        showLog("calculateRatio2 ${imageSize.height! > studioSize.height!}");

        // is portrait
        /*if (imageSize.height! > studioSize.height!)*/
        {
          convertedHeight = studioSize.width!.toDouble();
          double deductionOfHeight = imageSize.height! / studioSize.width!;
          showLog("portrait image $convertedHeight");
          ratio = deductionOfHeight.toString();

          convertedWidth = double.parse(
              (imageSize.width! / deductionOfHeight).round().toString());
        }
      } else {
        // is landscape
        showLog("calculateRatio3 ${imageSize.width! > studioSize.width!} ");

        /*if (imageSize.width! > studioSize.width!)*/
        {
          convertedWidth = studioSize.width!.toDouble();
          double deductionOfWidth = imageSize.width! / studioSize.width!;
          showLog("calculateRatio $deductionOfWidth");
          ratio = deductionOfWidth.toString();

          convertedHeight =
              double.parse("${imageSize.height! / deductionOfWidth}");
        }
      }
      showLog(
          "targeted ratio albums $convertedHeight x $convertedWidth ${studioSize.height} x ${studioSize.width}");

      if (convertedHeight != 0 && convertedWidth != 0) {
        showLog("convertedHeight convertedHeight $convertedHeight");

        ImageUtil imageUtil = ImageUtil();
        Uint8List? byte = Platform.isAndroid 
            ? await imageUtil.compressImageForAndroid({
                'path': file.path,
                'targetedHeight': convertedHeight.toInt(),
                'targetedWidth': convertedWidth.toInt(),
              })
            : await compute(imageUtil.compressImageForDesktopInIsolate, {
                'path': file.path,
                'targetedHeight': convertedHeight.toInt(),
                'targetedWidth': convertedWidth.toInt(),
              });
        if (byte == null && !Platform.isAndroid) {
          byte = await imageUtil.compressImageForDesktopInIsolate({
            'path': file.path,
            'targetedHeight': convertedHeight.toInt(),
            'targetedWidth': convertedWidth.toInt(),
          });
        } else {
          showLog("byte is not null");
        }
        bytes = byte;
      }
      return Compression(bytes, ratio);
    }
    return null;
  }
//
// Future<void> calculateRatio(
//     String ratio, String path, OrderModelDao model) async {
//   await model.updateImageRatio(ratio.toString(), path);
//   showLog("calculateRatio calculateRatio model $ratio $path");
//   return;
// }
}

class Compression {
  Uint8List? uint8list;
  String ratio;

  Compression(this.uint8list, this.ratio);
}
