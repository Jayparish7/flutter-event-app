import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as IMG;
import 'package:image_size_getter/image_size_getter.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/file_utils.dart';
import 'package:simple_native_image_compress/simple_native_image_compress.dart'
as nc;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:io';

class ImageUtil {
  static ImageSize getHeightOfFirstImage(Uint8List file) {
    try {
      // Image _image = Image.memory(file);
      if (file.isEmpty) {
        showLog("Image file is empty");
        return ImageSize(height: 6016, width: 4000);
      }

      final size = ImageSizeGetter.getSize(MemoryInput(file));
      showLog('size ImageSizeGetter $size');
      if (size.needRotate) {
        final width = size.height;
        final height = size.width;
        return ImageSize(height: height, width: width);
      } else {
        return ImageSize(height: size.height, width: size.width);
      }
    } catch (e, s) {
      showLog("some error $e,$s");
      return ImageSize(height: 6016, width: 4000);
    }
  }

  static Uint8List? resizeImage(Uint8List data, int width, int height) {
    showLog("rezize $width $height");
    Uint8List resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    if (img != null) {
      IMG.Image resized = IMG.copyResize(img, width: width, height: height);
      resizedData = IMG.encodeJpg(resized);
      return resizedData;
    } else {
      return null;
    }
  }

  Future<Uint8List?> resizeImageIso(Uint8List data, int width,
      int height) async {
    return await compute(
        _resizeImageCompute, {'data': data, 'width': width, 'height': height});
  }

  Uint8List? _resizeImageCompute(Map<String, dynamic> args) {
    Uint8List data = args['data'];
    int width = args['width'];
    int height = args['height'];

    IMG.Image? img = IMG.decodeImage(data);
    if (img != null) {
      try {
        IMG.Image resized = IMG.copyResize(img, width: width, height: height);
        return IMG.encodeJpg(resized);
      } catch (e) {
        // Handle errors here
        print("Error resizing image: $e");
        return null;
      }
    } else {
      // Handle errors here
      print("Error decoding image data");
      return null;
    }
  }

/*
  Future<File> compressAndSaveImage(String path) async {
    showLog('compressAndSaveImage nc.ImageCompress');
    final file = File(path);

// Read the image file as bytes
    final bytes = await nc.ImageCompress.contain(
      filePath: path,
      compressFormat: nc.CompressFormat.jpeg,
      samplingFilter: nc.FilterType.lanczos3,
    );
// Get the Downloads directory
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception("Downloads directory is not available");
    }

// Define a unique file path for the compressed image in Downloads
    final newPath =
        '${downloadsDir.path}/compressed_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newFile = File(newPath);

// Write the compressed bytes to the file
    await newFile.writeAsBytes(bytes);

    return newFile;
  }*/

    Future<Uint8List> compressImageForDesktop(String path, int targetedHeight,
        int targetedWidth) async {
      showLog('compressImageForDesktop 123456 $targetedHeight ,$targetedWidth');
      final file = File(path);
      final bytes = await nc.ImageCompress.contain(
          filePath: path,
          samplingFilter: nc.FilterType.lanczos3,
          quality: 50,
          maxHeight: targetedHeight,
          maxWidth: targetedWidth);
      showLog('compressImageForDesktop Input size = ${file.lengthSync()}');

      showLog('compressImageForDesktop Output size = ${bytes.length}');

      return bytes;
    }

  Future<Uint8List?> compressImageForDesktopInIsolate(
      Map<String, dynamic> params) async {
    if (!Platform.isAndroid) {
      await nc.NativeImageCompress.init();
    }
    DateTime diff = DateTime.now();
    showLog(
        'compressImageForDesktopInIsolate params lanczos3: ${DateTime
            .now()} ${params['path']}');
    final file = File(params['path']);
    Uint8List? bytes;
    try {
      bytes = await nc.ImageCompress.contain(
        filePath: params['path'],
        samplingFilter: nc.FilterType.lanczos3,
        quality: 50,
        maxHeight: params['targetedHeight'],
        maxWidth: params['targetedWidth'],
      );
//       // Step 1: Read image bytes from the file
//       final imageBytes = await file.readAsBytesSync();
//
//       // Decode image
//       img.Image? image = img.decodeImage(imageBytes);
// // Step 3: Flatten to white if needed
//       if (image != null) {
//         final safeImage = flattenToWhite(image);
//         showLog("flattenToWhite worked");
//
//         // Resize image (optional)
//         img.Image resized = img.copyResize(
//           safeImage,
//           width: params['targetedWidth'],
//           height: params['targetedHeight'],
//           interpolation: img.Interpolation.average,
//         );
//
//         // Encode as JPEG with quality 70%
//         Uint8List compressedBytes =
//         Uint8List.fromList(img.encodeJpg(resized, quality: 90));
    }
    catch (e) {
      showLog("eee $e");

      return bytes;
    }
    showLog(
        'compressImageForDesktopInIsolate Input size = ${file.lengthSync()}');
    showLog(
        'compressImageForDesktopInIsolate Output size ${diff.difference(
            DateTime.now())} = ${bytes?.length}');
    return bytes;
  }

  static IMG.Image flattenToWhite(IMG.Image img) {
    if (!img.hasAlpha) return img;
    final bg = IMG.Image(width: img.width, height: img.height);
    IMG.fill(
      bg,
      color: IMG.ColorRgb8(255, 255, 255),
    ); // white background
    IMG.compositeImage(bg, img);
    return bg;
  }

  Future<Uint8List?> compressImageForAndroid(
      Map<String, dynamic> params) async {
    DateTime diff = DateTime.now();
    showLog(
        'compressImageForAndroid params: ${DateTime.now()} ${params['path']}');
    final file = File(params['path']);
    final bytes =  await FlutterImageCompress
        .compressWithFile(params['path'],
        minHeight: params['targetedHeight'],
        minWidth: params['targetedWidth'],
        quality: 95);
    showLog('compressImageForAndroid Input size = ${file.lengthSync()}');
    showLog(
        'compressImageForAndroid Output size ${diff.difference(
            DateTime.now())} = ${bytes?.length}');
    return bytes;
  }

  static Future<Uint8List?> compressImageToUint8List(String imagePath,
      int screenDisplay) async {
    // Read image file
    FileUtil fileUtil = FileUtil();
    showLog("compressImageToUint8List");
    File file = File(imagePath);
    Uint8List imageBytes = await file.readAsBytes();
    ImageSize studioSize = await fileUtil.getStudioSize(screenDisplay ?? 4);

    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
// Step 3: Flatten to white if needed
    if (image != null) {
      final safeImage = flattenToWhite(image);
      showLog("flattenToWhite worked");

      // Resize image (optional)
      img.Image resized = img.copyResize(
        safeImage,
        width: studioSize.width,
        height: studioSize.height,
        interpolation: img.Interpolation.average,
      );

      // Encode as JPEG with quality 70%
      Uint8List compressedBytes =
      Uint8List.fromList(img.encodeJpg(resized, quality: 90));

      return compressedBytes;
    }
    return null;
  }
}

class ImageSize {
  int? height;
  int? width;

  ImageSize({this.height, this.width});
}
