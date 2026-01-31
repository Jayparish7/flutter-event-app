import '../../database/object_box_model/object_box_models.dart'as box;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../api/apiResponseModels/photoSelection_reverse_confirmation_response_model.dart';
import '../../api/apiResponseModels/photoselection_details_for_Notification_response_model.dart';
import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../common_widgets/base_widget.dart';
import '../../main.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';

class InboxRouteViewModel extends BaseObserver {
  List<box.Notification> inbox = [];
  List<PhotoSelectionDetailsForNotificationResponseModel>
  eventNotificationResponse = [];
  List<String> imageUrls = [];
  List<String> notificationTitle = [];
  final notificationsDao = objectBox.notificationsDao;

  String? messageTitle;
  bool isLoading = false;
  bool isBtnLoading = false;
  TransporterResponse? studioData;

  String publicPath = '';
  String studioCode = '';
  Api api = Api(null);

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialData() async {
    isLoading = true;
    notifyListeners();
    await getStudioData();
    inbox = await notificationsDao.getNotificationsData() ?? [];
    if (inbox.isNotEmpty) {
      for (int i = 0; i < inbox.length; i++) {
        PhotoSelectionDetailsForNotificationResponseModel decodedData =
        photoSelectionDetailsForNotificationResponseModelFromJson(
            inbox[i].notificationData!);
        eventNotificationResponse.add(decodedData);
      }
      for (int i = 0; i < eventNotificationResponse.length; i++) {
        imageUrls.add(
            eventNotificationResponse[i].data!.eventCoverImage!.jvtFile!.name!);
      }
      showLog(
          'getInitialData - InboxRouteViewModel in $inbox');
    }
    isLoading = false;
    notifyListeners();
  }

  getStudioData() async {
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    //showLog('res2res2res2res2 ${prefsStudioData}');
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    studioData = transporterResponseFromJson(prefsStudioData);
    if (studioData?.studiosData![studioIndex].data != null &&
        studioData!.studiosData![studioIndex].data!.packages!.isNotEmpty) {
      publicPath = studioData!.studiosData![studioIndex].data!.publicStoragePath!;
      studioCode = studioData!.studiosData![studioIndex].data!.code!;

      showLog('getStudioData inbox $studioCode }');
    }
  }

  updateReadStatus(int id) async {
    await notificationsDao.updateReadStatusWhereId(id: id);

    inbox.clear();
    getInitialData();
  }


  reverseConfirmationApi(
      {required String eventCode, required String studioCode , required int id}) async {
    isBtnLoading =true;
    notifyListeners();
    PhotoselectionReverseConfirmationResponseModel? response = await api.photoSelectionReverseConfirmationApiCall(
        eventCode: eventCode, studioCode: studioCode);
    if(response!=null && response.message!=null){
      Fluttertoast.showToast(
          msg: response.message??"",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 18,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
      await notificationsDao.updateConfirmationStatusWhereId(id: id);
      showLog('reverseConfirmationApi $response');

      inbox.clear();
      getInitialData();
    }
    isBtnLoading =false;
    notifyListeners();
  }
}
