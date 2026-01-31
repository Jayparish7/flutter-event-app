import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../api/apiResponseModels/EventSettingsShowResponseModel.dart';
import '../../api/api_call.dart';

class EventSettingsViewModel extends BaseObserver {
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Api api = Api(null);

  getInitialData(String eventCode) {
    var res =eventSettingsShowApiCall(eventCode);
    showLog('getInitialData  $res');
  }


  Future<EventSettingsShowResponse?> eventSettingsShowApiCall(String eventCode) async {
    EventSettingsShowResponse? response;
   try {
      response = await api.eventSettingsShowApiCall(
          eventCode: eventCode);
      showLog('EventSettingsShowResponse ${response?.photomallEvent?.settings}');
    }catch(e){
     showLog('error in eventSettingsShowApiCall $e');
   }
    return response;
  }


}