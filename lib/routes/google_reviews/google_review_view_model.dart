import 'dart:convert';

import 'package:photomall_studio_manager/common_widgets/base_widget.dart';

import '../../api/apiResponseModels/transporter_response_model.dart';
import '../../preference/preference_constants.dart';
import '../../preference/preference_helper.dart';
import '../1.constants/common_constants.dart';

class GoogleReviewViewModel extends BaseObserver{
   List<Review> reviews =[];
   bool isGoogleReviewAvailable = false;

  TransporterResponse ? studioData;
  bool  isLoading = false;
  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }


  getInitialData()async{
    notifyListeners();
    isLoading =true;
  await   getGoogleReviewFromStudioData();
    showLog('getInitialData $reviews');

    isLoading = false;
    notifyListeners();

  }




  getGoogleReviewFromStudioData() async {
    var prefsStudioData = await PreferenceHelper.getString(studioDataKey);
    showLog('getGoogleReviewFromStudioData $prefsStudioData');

    studioData =
        transporterResponseFromJson(prefsStudioData);
    int studioIndex = await PreferenceHelper.getInt(studioIndexKey);
    showLog('studioIndex is $studioIndex');
    List<GoogleReview>? googleReview = studioData!.studiosData?[studioIndex].data?.googleReviews;

    if (googleReview!.isNotEmpty) {
      reviews = googleReview[studioIndex].reviews!;
      //isGoogleReviewAvailable = true;
    }

  }

}


List<GoogleReview> googleReviewFromJson(String str) => List<GoogleReview>.from(
    json.decode(str).map((x) => GoogleReview.fromJson(x)));