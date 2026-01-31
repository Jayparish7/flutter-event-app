import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/country_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/device_register_model.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/controllers/app_update_controller.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/utils/device_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/apiResponseModels/app_update_response_model.dart';
import '../../redirection/redirection_controller.dart';
import '../1.constants/redirection_constants.dart';
import '../studioDetail/event_argument_model.dart';

class SplashScreenController extends BaseObserver {
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;

  SplashScreenController({
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  bool isLoading = false;
  String deviceId = "";

  bool devRegStatus = false;
  double opacity = 1;
  double scale = 0.3;
  Api api = Api(null);

  Future<void> getInitialValues() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
     //await preferences.clear();

    isLoading = true;

    bool isDeviceRegistred = await getDeviceRegisterStatus();

    if (!isDeviceRegistred) {
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
      showLog("close the app");
    }

    RedirectionController redirectionController = RedirectionController();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = await PreferenceHelper.getBool(isLoggedInPreferenceKey);
    await PreferenceHelper.setBool(studioDetectedKey, false);

    String? redirection = preferences.getString(redirectionConstantsKey);
    AppUpdate? appUpdate = await api.appUpdateApiCall();
    showLog('appUpdateApiCall ${appUpdate?.appUpdateStatus}');
    await prefs.setString(
        updateStatusKey, appUpdate?.appUpdateStatus.toString() ?? '');
    showLog('is redirection $redirection');
    Timer(const Duration(milliseconds: 0), () {
      opacity = 1.0;
      scale = 1.0;
      notifyListeners();
    });
    Timer(const Duration(seconds: 2), () {
      isLoading = false;
      (res != true)
          ? Navigator.pushReplacementNamed(
              context,
              RoutePaths.login,
            )
          : (redirection != null)
              ? redirectionController.redirectionToRoute()
              : Navigator.pushReplacementNamed(
                  context,
                  RoutePaths.sideMenuView,
          arguments: SideMenuArguments(0)
                );
    });
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  Future<bool> getDeviceRegisterStatus() async {
    DateTime date = DateTime.parse("2023-06-07 18:18:44.115648");
    int epochDate = date.millisecondsSinceEpoch;
    showLog("Date time $date \n epoch : $epochDate");

    try {
      devRegStatus =
          await PreferenceHelper.getBool(isDeviceRegisteredPreferenceKey);
      if (!devRegStatus) {
        showLog("Device Registering ..");
        DeviceUtil deviceUtil = DeviceUtil();
        Map<String, dynamic> deviceMap = await deviceUtil.getDeviceInfo();
        try{
          deviceMap["device_memory"] = !Platform.isAndroid
              ? await deviceUtil.getDeviceMemoryForDesktop()
              : await deviceUtil.getDeviceMemoryForAndroid();
        }catch(e){}
        if(!Platform.isAndroid){
          deviceMap["processor"] = await deviceUtil.getDeviceProcessor();
        }

        DeviceRegisterModel? response =
            await Api(context).devRegApiCall(deviceMap);
        if (response != null && response.data != null) {
          showLog('the device id where >> ');
          (!Platform.isAndroid)
              ? await PreferenceHelper.setString(deviceIdPreferenceKey,
                  deviceMap["device"]["desktop_device_uuid"])
              : await PreferenceHelper.setString(deviceIdPreferenceKey,
                  deviceMap["app"]?["device"]?["android_device"]);
          await PreferenceHelper.setString(
              countryPreferenceKey, getCountryString(response.data!.countries));

          await PreferenceHelper.setBool(isDeviceRegisteredPreferenceKey, true);
          await PreferenceHelper.setString(
              clientSecretPreferenceKey, response.data!.clientSecret!);
        }
      } else {
        showLog("Device already Registered ...");
      }
      return true;
    } catch (e, s) {
      showLog("the error is $s");
      return false;
    }
  }

  String getCountryString(List<Country>? countries) {
    String country = jsonEncode(countries!.map((e) {
      return e.toJson();
    }).toList());
    showLog("country : $country");
    return country;
  }
}
