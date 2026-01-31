import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../1.constants/common_constants.dart';

class ShareViewModel extends BaseObserver {
  TransporterResponse? studioData;
  List<String> domainUrls = [];
  String playStoreUrl = '';
  String shortUrl = '';
  String domainLink = '';
  bool isLoading = false;
  bool isHovered = false;
  List<String> downloadSize = ['500'];
  List<String> sizeList = [
    '500 x 500',
    '100 x 100',
    '200 x 200',
    '1000 x 1000',
    '1500 x 1500',
    '2000 x 2000',

  ];

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialData() async {
    isLoading = true;
    notifyListeners();
    await getStudioData();
    isLoading = false;
    notifyListeners();
  }

  getStudioData() async {
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    //showLog('res2res2res2res2 ${prefsStudioData}');
    studioData = transporterResponseFromJson(prefsStudioData);
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!.studiosData![studioIndex].data!.jvtFileConnectors!.isNotEmpty) {
      domainUrls.add(studioData!.studiosData![studioIndex].data!.domainUrl!);
      playStoreUrl = studioData!.studiosData![studioIndex].data!.playStoreUrl!;
      shortUrl = studioData!.studiosData![studioIndex].data!.shortUrl!;
      domainLink = studioData!.studiosData![studioIndex].data!.ptmlDomain!;

      showLog('getStudioData $prefsStudioData in share $domainUrls ,$playStoreUrl ,');
    }
  }

  Future<void> downloadQrCode(String data, int size,String qrName) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: Colors.white,
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
        emptyColor: Colors.black, // White background for QR code
      );

      // Generate the image data with the specified size
      final picData = await painter.toImageData(size.toDouble());
      final buffer = picData!.buffer.asUint8List();

      // Get the directory to save the file
      final directory = await getDownloadsDirectory();
      final path = directory!.path;
      final file = File('$path/$qrName-qr_code_${size}x$size.png');

      // Write the image data to the file
      await file.writeAsBytes(buffer);
      ToastUtil.showSnackBarAtCurrentState('Downloaded successfully to $path/$qrName-qr_code_${size}x$size.png',seconds: 5,actions: SnackBarAction(label: 'Open', onPressed: () async {  if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      }else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }else if (Platform.isAndroid) {
        // Open the file on Android
       // final result = await OpenFile.open(path);
       // showLog('Platform.isAndroid type ${result.type}');
       // if (result.type.toString() != result.type.toString()) {
          // Handle error if the file cannot be opened
         // showLog('Error opening file: ${result.message}');
       // }
      } else if (Platform.isIOS) {
        // Handle iOS if necessary
       // final result = await OpenFile.open(path);
       // if (result.type.toString() != result.type.toString()) {
        //  showLog('Error opening file: ${result.message}');
      //  }
      }

      }));
      showLog('Downloaded successfully to $path/qr_code_${size}x$size.png');
    } catch (e) {
      showLog('Error: $e');
    }
  }


}
