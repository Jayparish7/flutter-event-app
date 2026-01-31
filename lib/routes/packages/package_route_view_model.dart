import 'package:flutter/cupertino.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../1.constants/common_constants.dart';

class PackageRouteViewModel extends BaseObserver {

  ValueNotifier<bool>  isLoading = ValueNotifier<bool>(false);
  String publicPath ='';
  TransporterResponse? studioData;
  List<Package?> packages = [];
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }



  getInitialData() async {
    isLoading.value = true;
    notifyListeners();

    await getStudioData();
    isLoading.value = false;
    notifyListeners();
  }

  getStudioData() async {
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    //showLog('res2res2res2res2 ${prefsStudioData}');
    studioData = transporterResponseFromJson(prefsStudioData);
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!.studiosData![studioIndex].data!.packages!.isNotEmpty) {

      packages  = studioData!.studiosData![studioIndex].data!.packages!;
      publicPath  = studioData!.studiosData![studioIndex].data!.publicStoragePath!;

      showLog('getStudioData in$publicPath packages route ${packages[studioIndex]!.priorityScore}');
    }
  }

}