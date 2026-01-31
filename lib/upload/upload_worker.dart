// import 'dart:io';
// import 'dart:typed_data';
// import 'package:mime/mime.dart';
// import 'package:path/path.dart' as path;
//
// import '../api/apiRequestModels/digital_oceans_space_service.dart';
// import '../api/api_call.dart';
// import '../database/object_box_model/object_box_models.dart';
// import '../main.dart';
// import '../objectbox.g.dart';
// import '../preference/preference_constants.dart';
// import '../preference/preference_helper.dart';
// import '../routes/1.constants/common_constants.dart';
//
//
// class UploadWorker {
//   final orderModelDao = objectBox.orderModelDao;
//   final eventModelDao = objectBox.eventModelDao;
//   final api = Api(null);
//
//   Future<void> start() async {
//     while (true) {
//       await _uploadMainImage();
//       await _uploadScreenDisplay2Image();
//       await Future.delayed(const Duration(seconds: 5));
//     }
//   }
//
//   Future<void> _uploadMainImage() async {
//     final order = orderModelDao.getImageForUpload();
//     if (order == null) return;
//
//     final event = eventModelDao.getEventWhereCode(order.eventCode ?? "");
//     if (event == null) return;
//
//     await _uploadToSpace(
//       order: order,
//       screenDisplay: event.screenDisplay,
//       isForDisplay: false,
//     );
//   }
//
//   Future<void> _uploadScreenDisplay2Image() async {
//     final order = orderModelDao.getImageForUploadForScreenDisplay2();
//     if (order == null) return;
//
//     final event = eventModelDao.getEventWhereCode(order.eventCode ?? "");
//     if (event == null) return;
//
//     await _uploadToSpace(
//       order: order,
//       screenDisplay: 2,
//       isForDisplay: true,
//       largeJvtFileCode: order.code!,
//     );
//   }
//
//   Future<void> _uploadToSpace({
//     required OrderImage order,
//     required int screenDisplay,
//     required bool isForDisplay,
//     String largeJvtFileCode = '',
//   }) async {
//     try {
//       final originalPath = await PreferenceHelper.getString(originalFilePathKey);
//       final studioCode = await PreferenceHelper.getString(studioCodePrefKey);
//       final imageFile = File(order.path!);
//
//       if (!imageFile.existsSync() || !imageFile.path.contains(order.name!)) return;
//
//       final extension = lookupMimeType(imageFile.path) ?? "jpeg";
//       final service = DigitalOceanSpacesService(originalFilePath: originalPath);
//       final bytes = isForDisplay ? order.screenDisplay2imageBytes : order.imageBytes;
//
//       if (bytes == null || bytes.isEmpty) return;
//
//       final uniqueName = isForDisplay ? order.screenDisplay2ImageUrl! : order.sha256!;
//       final ratio = isForDisplay ? order.screenDisplay2ratio : order.ratio;
//
//       final size = await service.getImageDimensions(bytes);
//
//       final uploadResult = await service.uploadFile(
//         path: imageFile.path,
//         bytes: bytes,
//         objectKey: uniqueName,
//         extension: extension,
//         eventCode: order.eventCode!,
//         ableCode: order.albumCode,
//         ableType: "albums",
//         ratio: ratio!,
//         isFromCompressForScreenDisplay2: screenDisplay == 2,
//         isFromCompute: isForDisplay,
//       );
//
//       if (uploadResult.hash.isEmpty || uploadResult.hash == 'Already Uploaded') return;
//
//       final response = await api.imageUploadApiCall(
//         type: "albums",
//         ableCode: order.albumCode,
//         filePath: originalPath,
//         studioCode: studioCode,
//         jvtFileName: uniqueName,
//         fileName: order.name!,
//         imageHash: uploadResult.hash,
//         eventCode: order.eventCode!,
//         extension: extension,
//         preSignedUrlCode: uploadResult.preSignedURlCode,
//         screenDisplay: screenDisplay.toString(),
//         imageWidth: size.width.toString(),
//         imageHeight: size.height.toString(),
//         ratio: ratio,
//         isFromCompressForScreenDisplay2: isForDisplay,
//         largeJvtFileCode: largeJvtFileCode,
//       );
//
//       if (response != null) {
//         if (isForDisplay) {
//           orderModelDao.clearImageBytesForScreenDisplay2(order.id);
//         } else {
//           orderModelDao.clearImageBytes(order.id);
//         }
//
//         orderModelDao.updateImageFileCode(order.id, response.file!.jvtFileCode!);
//
//         if (screenDisplay != 4) {
//           orderModelDao.updateImageUploadedStatusTrue(order.id, 3, path: imageFile.path);
//         }
//       }
//     } catch (e) {
//       showLog("UploadWorker error: $e");
//     }
//   }
// }
