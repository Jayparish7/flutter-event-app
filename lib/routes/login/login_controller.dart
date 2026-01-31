import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/country_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/login_model.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/otp_response_model.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/api/api_helper.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/oauth/oauth_methods.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import '../../utils/permission_util.dart';
import '../studioDetail/event_argument_model.dart';

List<Country>? allCountries;

class LoginController extends BaseObserver {
  BuildContext context;
  ApiHelper? apiHandler;
  Api? apiRepo;
  String userName = "";
  int countryId = 108;

  LoginController({
    required this.context,
    this.apiHandler,
  }) {
    apiRepo = Api(context);
  }

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<bool?> userApi(String user, id) async {
    isLoading.value = true;
    Api api = Api(context);
    userName = user;
    if (id != null) {
      countryId = id;
    }
    showLog('loginStatus loginStatus');

    LoginModel ?loginStatus;

    try{
      loginStatus = await api.userNameApiCall(user, id);
    }catch(e){
      showLog('loginStatus $e');

    }
    showLog('loginStatus $loginStatus');
    isLoading.value = false;
    if (loginStatus?.status == 1) {
      await PreferenceHelper.setInt(
          clientIdPreferenceKey, loginStatus?.clientId ?? 0);
      return true;
    } else {
      return false;
      String message = loginStatus?.errorMessage ?? "not valid";

      ToastUtil.getToast(context, 'Error', message);
    }
    return null;
  }

  Future<void> otpApi(String otp, BuildContext context,{String user ='',bool trueCaller =false}) async {
    int clientId = await PreferenceHelper.getInt(clientIdPreferenceKey);
    if(user!=''){
      userName =user;
    }
    isLoading.value = true;
    Api api = Api(context);
    try {
      OtpResponse? otpResponse =
          await api.otpApiCall(userName, otp, countryId, clientId,trueCaller: trueCaller);
      if (otpResponse != null) {
        await OauthMethods.setLogin(true);
        showLog('otp page em ');
        //await PreferenceHelper.setBool(isLoggedInPreferenceKey, true);
        var res = await PreferenceHelper.getBool(isLoggedInPreferenceKey);
        showLog('is login controller in $res');
        await OauthMethods.setOauthInPreference(OauthObject(
            accessToken: otpResponse.accessToken!,
            refreshToken: otpResponse.refreshToken!,
            expiresIn: otpResponse.expiresIn!));
        navigate(context);
      }
    } catch (e) {
      ToastUtil.getToast(context, 'Error', "OTP not valid");
    }

    isLoading.value = false;
    return;
  }

  @override
  void onInternetConnectionBack() {
    // TODO: implement onInternetConnectionBack
  }

  getInitialValues(BuildContext context) async {
    try {
      //requestPermissionForAndroid(context);
      String countriesString =
          await PreferenceHelper.getString(countryPreferenceKey);
      allCountries = List<Country>.from(
          json.decode(countriesString).map((x) => Country.fromJson(x)));
    } catch (e) {
      showLog('the country error where $e');
    }
  }

  void navigate(BuildContext context) async {
    // this function pop all previous until login
    Navigator.popUntil(
      context,
      ModalRoute.withName(RoutePaths.login),
    );
    // this navigate to event index
    Navigator.pushNamed(
      context,
      RoutePaths.sideMenuView,
        arguments: SideMenuArguments(0)
    );
  }
}

class Tuple {
  final Country? object;
  final String? phoneNumber;

  Tuple({
    this.object,
    this.phoneNumber,
  });
}
