import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/database/dao/image_dao.dart';

import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:uuid/uuid.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../database/object_box_model/object_box_models.dart';
import '../../main.dart';
import '../../preference/preference_constants.dart';
import '../../routes/1.constants/common_constants.dart';
import '../../utils/device_util.dart';
import '../../utils/image_util.dart';
import '../apiResponseModels/file_upload_credentials_response_model.dart';
import '../apiResponseModels/pre_signed_url_api_response_model.dart';
import '../apiResponseModels/transporter_response_model.dart';
import '../api_call.dart';

class DigitalOceanSpacesService {
  final String originalFilePath;

  DigitalOceanSpacesService({
    required this.originalFilePath,
  });

  ImageSize getImageDimensions1(Uint8List uint8List) {
    // Decode the image from Uint8List
    img.Image? image = img.decodeImage(uint8List);

    if (image == null) {
      throw Exception("Invalid image data");
    }

    // Return width and height
    return ImageSize(
      height: image.height,
      width: image.width,
    );
  }

  Future<ImageSize> getImageDimensions(Uint8List uint8List) async {
    return ImageUtil.getHeightOfFirstImage(uint8List);
  }

  Api api = Api(null);
  final imageModelDao = objectBox.imageModelDao;

  final orderModelDao = objectBox.orderModelDao;

  Future<UploadFileResponse> uploadFile(
      {bytes,
      required String objectKey,
      required String extension,
      required String eventCode,
      required String ableCode,
      required String ableType,
      required String path,
      String ratio = '',
      bool isFromCompressForScreenDisplay2 = false,
      bool isFromCompute = false}) async {
    showLog('imageUploadResponse uploadFile $objectKey ');
    try {
      {
        UploadFileResponse uploadFileResponseFromDb =
            await checkImageIsAlreadyUploaded(
                ableType: ableType,
                sha256: objectKey,
                isFromCompressForScreenDisplay2:
                    isFromCompressForScreenDisplay2);
        if (uploadFileResponseFromDb.preSignedURlCode != '' &&
            uploadFileResponseFromDb.hash != '') {
          return uploadFileResponseFromDb;
        }
      }
      PreSignedUrlResponseModel? res = await api.generatePreSignedUrlApiCall(
        eventCode: eventCode,
        ableCode: ableCode,
        ableType: ableType,
        filePath: originalFilePath,
        fileName: objectKey,
      );
      showLog("generatePreSignedUrlApiCall  uploadFileToS3 ");
      if (res != null && res.presignedUrl != null) {
        return await uploadFileToS3(bytes, res.presignedUrl ?? '',
            res.presignedUrlCode ?? "", extension, ableType, objectKey, path,
            isFromCompressForScreenDisplay2: isFromCompressForScreenDisplay2,
            isFromCompute: isFromCompute);
      } else {
        showLog("presignedUrl is null");
        if (res != null && res.errorMessage != null) {
          return UploadFileResponse(
              hash: res.errorMessage ?? 'Already Uploaded',
              preSignedURlCode: '');
        }
      }
    } catch (e, s) {
      // await InterNetProvider.waitForInternet();

      try {
        DeviceUtil deviceUtil = DeviceUtil();
        await deviceUtil.callChatNotifier('$e', '$s');

        Platform.isWindows
            ? WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused)
            : null;
        showLog('Error uploading file: $e');
        if (e.toString().contains('RequestTimeTooSkewed') ||
            e.toString().contains('ClientException with SocketException')) {
          bool? isTimeSynced = await deviceUtil.checkSystemTime(null);
          showLog('isTimeSynced is before $isTimeSynced');

          if (isTimeSynced != null && !isTimeSynced) {
            showLog('isTimeSynced $isTimeSynced');
            await ToastUtil.showSnackBarAtCurrentState(
                "Your system date & time may be incorrect.Please change the correct date and time.",
                seconds: 10,
                actions: SnackBarAction(
                    label: "Change Date & Time",
                    onPressed: () {
                      deviceUtil.openDateTimeSettings();
                    }));
          }
        }
        FileUploadCredentials.setUploadCredentialsToPreference();
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        showLog('catch error catch');
      }
    }
    return UploadFileResponse(preSignedURlCode: '', hash: "");
  }

  Future<UploadFileResponse> uploadFileToS3(
      Uint8List bytes,
      String presignedUrl,
      String preSignedUrlCode,
      String extension,
      String ableType,
      String sha256,
      String path,
      {bool isFromCompressForScreenDisplay2 = false,
      bool isFromCompute = false}) async {
    try {
      if (presignedUrl == '') {
        showLog("uploadFileToS3 presigned url is null");
        return UploadFileResponse(
          preSignedURlCode: '',
          hash: "",
        );
      }
      Dio dio = Dio();
      Response response = await dio.put(
        presignedUrl,
        data: bytes,
        options: Options(
          headers: {
            "Content-Type": "image/$extension",
            "x-amz-acl": "public-read",
          },
          sendTimeout: const Duration(seconds: 300),
          receiveTimeout: const Duration(seconds: 300),
        ),
      );

      showLog("response response response ${response.headers.value("etag")}");

      if (response.statusCode == 200) {
        await updateImageHash(
            ableType: ableType,
            md5hash: response.headers.value("etag") ?? "",
            sha256: sha256,
            presignedUrlCode: preSignedUrlCode,
            path: path,
            isFromCompressForScreenDisplay2: isFromCompressForScreenDisplay2,
        isFromCompute: isFromCompute
        );

        showLog('File uploaded successfully.$response');
        // Check if response contains a redirect URL
        String? redirectUrl = response.headers.value("location");
        String publicUrl = presignedUrl.split("?").first;
        showLog("✅ Image uploaded successfully!");
        showLog("📌 Image URL: ${redirectUrl ?? publicUrl}");

        return UploadFileResponse(
            hash: response.headers.value("etag") ?? "",
            preSignedURlCode: preSignedUrlCode);
      } else {
        showLog('Failed to upload file. Status code: ${response.extra}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.sendTimeout) {
        showLog('Connection timed out.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        showLog('Receive timeout.');
      } else if (e.type == DioExceptionType.badResponse) {
        showLog('Server error. Status code: ${e.response?.statusCode}');
      } else {
        showLog('Error uploading file: $e');
      }
    } catch (e) {
      showLog('Unexpected error: $e');
    }
    return UploadFileResponse(preSignedURlCode: '', hash: "");
  }

  Future<UploadFileResponse> checkImageIsAlreadyUploaded({
    required String ableType,
    required String sha256,
    bool isFromCompressForScreenDisplay2 = false,
  }) async {
    showLog("checkImageIsAlreadyUploaded $ableType");
    if (ableType == "albums") {
      if (isFromCompressForScreenDisplay2 != true) {
        OrderImage ? order =   orderModelDao.getImageWhereSha256(sha256);
        if (order != null &&
            order.md5hash != null &&
            order.preSignedURlCode != null) {
          showLog(
              "alreadyUploaded order ${order.preSignedURlCode} ,${order.md5hash} ");
          return UploadFileResponse(
              hash: order.md5hash!, preSignedURlCode: order.preSignedURlCode!);
        } else {
          return UploadFileResponse(preSignedURlCode: '', hash: '');
        }
      } else {
        OrderImage? order =
              orderModelDao.getImageWhereSha256ForScreenDisplay2(sha256);
        if (order != null &&
            order.screenDisplay2Md5hash != null &&
            order.screenDisplay2PreSignedURlCode != null) {
          showLog(
              "alreadyUploaded order ${order.screenDisplay2PreSignedURlCode} ,${order.screenDisplay2Md5hash} ");
          return UploadFileResponse(
              hash: order.screenDisplay2Md5hash!,
              preSignedURlCode: order.screenDisplay2PreSignedURlCode!);
        } else {
          return UploadFileResponse(preSignedURlCode: '', hash: '');
        }
      }
    } else {
      PhotoSelectionImage? photoSelectionImage =
          await imageModelDao.getImageWhereSha256(sha256);
      if (photoSelectionImage != null &&
          photoSelectionImage.md5hash != null &&
          photoSelectionImage.preSignedURlCode != null) {
        showLog(
            "alreadyUploaded photoSelectionImage ${photoSelectionImage.preSignedURlCode} ,${photoSelectionImage.md5hash} ");

        return UploadFileResponse(
            hash: photoSelectionImage.md5hash!,
            preSignedURlCode: photoSelectionImage.preSignedURlCode!);
      } else {
        return UploadFileResponse(preSignedURlCode: '', hash: "");
      }
    }
  }

  updateImageHash(
      {required String ableType,
      required String md5hash,
      required String sha256,
      required String presignedUrlCode,
      required String path,
      isFromCompressForScreenDisplay2 = false,
      bool isFromCompute = false}) async {
    showLog(
        "updateImageHash $ableType , $md5hash , $sha256 , $presignedUrlCode");
    if (ableType == "albums") {
      if (isFromCompressForScreenDisplay2 != true ){
          orderModelDao.updateImageMd5Hash(
            md5Hash: md5hash,
            sha256: sha256,
            presignedUrlCode: presignedUrlCode);
      }
      if (isFromCompressForScreenDisplay2 == true && isFromCompute == true) {
          orderModelDao.updateImageMd5HashForScreenDisplay2(
            md5Hash: md5hash,
            sha256: sha256,
            presignedUrlCode: presignedUrlCode);
      }
    } else {
      await imageModelDao.updateImageMd5Hash(
          md5Hash: md5hash, sha256: sha256, presignedUrlCode: presignedUrlCode);
    }
  }

  Future<String?> getFileUrl(String objectKey) async {
    try {
      final url = 'https://cdn.photomall.in/photomall/$objectKey';
      return url;
    } catch (e) {
      showLog('Error getting file URL: $e');
      return null;
    }
  }

  String generateUniqueId() {
    final String uuid = const Uuid().v4();
    final String randomDigits = getRandomString(8);
    return uuid + randomDigits;
  }

  // Function to generate a random string of given length
  String getRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}

class FileUploadCredentials {
  static setUploadCredentialsToPreference() async {
    Api api = Api(null);
    FileUploadCredentialsResponseModel? response =
        await api.fileUploadCredentialsApiCall();
    showLog("setUploadCredentialsToPreference");

    if (response != null) {
      await PreferenceHelper.setString(screenDisplayKey,
          jsonEncode(response.screenDisplay ?? screenDisplayAsset));
      await PreferenceHelper.setString(
          originalFilePathKey, response.originalFilePath ?? "photomall");
    }
  }
}

class UploadFileResponse {
  String hash;
  String preSignedURlCode;

  UploadFileResponse({required this.hash, required this.preSignedURlCode});
}
