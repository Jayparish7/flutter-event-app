import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';

class StudioProfileModel extends BaseObserver {
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Map<String, PreviewData> datum = {};
  TransporterResponse? studioData;
  bool isLoading = false;

  List<String> get urls => [
        'https://photomall.in/en',
        'https://pub.dev/packages/flutter_link_previewer/example'
      ];

  getInitialData() async {
    notifyListeners();
    isLoading = true;
    await Future.delayed(Duration(seconds: 5));
    getStudioData();
    isLoading = false;
    notifyListeners();
  }

  getPreviewData(PreviewData data, List<String> urls, index) {
    notifyListeners();
  }

  getStudioData() async {
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    //showLog('res2res2res2res2 ${prefsStudioData}');
    var logo = '';
    studioData = transporterResponseFromJson(prefsStudioData);
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!
            .studiosData![studioIndex].data!.jvtFileConnectors!.isNotEmpty) {
      urls.add(studioData!.studiosData![studioIndex].data!.domainUrl!);

      showLog(
          'urls ur${studioData!.studiosData![studioIndex].data!.domainUrl!}');
    }
  }
}
