import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/refresh_token_model.dart';
import 'package:photomall_studio_manager/api/constants/key_constants.dart';
import 'package:photomall_studio_manager/controllers/app_update_controller.dart';
import 'package:photomall_studio_manager/oauth/oauth_methods.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import 'constants/url_constants.dart';

class ApiHelper {
  //header for normal request
  var header = {'Accept': 'application/json', 'Authorization': ''};

  //header for json request
  var jsonHeader = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Authorization': ''
  };

  int reCallApi = 1;
/*
  Future<dynamic>   apiRequest(String url, Map<String, dynamic> map,
      {bool isShowProgress = true,
      bool showSnackBarIfError = true,
      BuildContext? context,bool isFormData = false}) async {
    if (url != deviceRegisterUrl) {
      if (url != appRegisterUrl) {
        String clientSecret = await PreferenceHelper.getString(clientSecretKey);
        map[clientSecretKey] = clientSecret;
      }
    }
    if (await OauthMethods.getLogin()) {
      OauthObject oauthObject = await OauthMethods.getOauthInPreference();
      jsonHeader['Authorization'] = 'Bearer ${oauthObject.accessToken}';
    }
    if (Platform.isLinux) {
      map[applicationCodeKey] = applicationCodeLinux;
    } else if (Platform.isMacOS) {
      map[applicationCodeKey] = applicationCodeMac;
    } else if (Platform.isWindows) {
      map[applicationCodeKey] = applicationCodeWindows;
    } else if (Platform.isAndroid) {
      map[applicationCodeKey] = applicationCodeAndroid;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    map[appVersionCodeKey] =  (Platform.isAndroid) ? androidAppVersionCode : appVersionCode;;

    showLog("Api req : $baseUrl$url");
    showLog("Header:$jsonHeader");
   showLog("Body:$map");
    final body = jsonEncode(map);
    showLog("encoded");
    try {
      var response = await http.post(Uri.parse('$baseUrl$url'),
          headers: isFormData ? {} : jsonHeader, body: isFormData ?map:body);
      showLog("Response : ${response.statusCode} \n ${response.body}");
      dynamic responseData = await processResponse(response, context);
      if (responseData == reCallApi) {
        return await apiRequest(
          url,
          map,
        );
      } else {
        return responseData;
      }
    } catch (e,s) {
      showLog("Response Error22: $e ,$s");
      await ToastUtil.showSnackBarAtCurrentState(
        'Please Check your Internet Connection',
        seconds: 5,
      );
    }
  }*/
  Future<dynamic> apiRequest(
      String url,
      Map<String, dynamic> map, {
        bool isShowProgress = true,
        bool showSnackBarIfError = true,
        BuildContext? context,
        bool isFormData = false,
      }) async {
    try {
      // Add client secret if the URL is not for device or app registration
      if (url != deviceRegisterUrl && url != appRegisterUrl) {
        String clientSecret = await PreferenceHelper.getString(clientSecretKey);
        map[clientSecretKey] = clientSecret;
      }

      // Add OAuth token if logged in
      if (await OauthMethods.getLogin()) {
        OauthObject oauthObject = await OauthMethods.getOauthInPreference();
        jsonHeader['Authorization'] = 'Bearer ${oauthObject.accessToken}';
      }

      // Add platform-specific application code
      if (Platform.isLinux) {
        map[applicationCodeKey] = applicationCodeLinux;
      } else if (Platform.isMacOS) {
        map[applicationCodeKey] = applicationCodeMac;
      } else if (Platform.isWindows) {
        map[applicationCodeKey] = applicationCodeWindows;
      } else if (Platform.isAndroid) {
        map[applicationCodeKey] = applicationCodeAndroid;
      }

      // Add app version code
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      map[appVersionCodeKey] = Platform.isAndroid ? androidAppVersionCode : appVersionCode;

      // Log request details
      showLog("Api req : $baseUrl$url");
      showLog("Header:$jsonHeader");
      showLog("Body:$map");

      var response;

      if (isFormData) {
        // Handle FormData request
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$url'));
        map.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        // Add headers if needed (e.g., Authorization)
        if (jsonHeader.containsKey('Authorization')) {
          request.headers['Authorization'] = jsonHeader['Authorization']!;
        }

        response = await http.Response.fromStream(await request.send());
      } else {
        // Handle JSON request
        final body = jsonEncode(map);
        response = await http.post(
          Uri.parse('$baseUrl$url'),
          headers: jsonHeader,
          body: body,
        );
      }

      // Log response
      showLog("Response : ${response.statusCode} \n ${response.body}");

      // Process the response
      dynamic responseData = await processResponse(response, context);
      if (responseData == reCallApi) {
        return await apiRequest(url, map);
      } else {
        return responseData;
      }
    } catch (e, s) {
      // Log error and show a snackbar
      showLog("api Response Error: $e ,$s");
      if (showSnackBarIfError) {
      /*  await ToastUtil.showSnackBarAtCurrentState(
          'Please Check your Internet Connection',
          seconds: 5,
        );*/return '$e & $url' ;
      }
      return null;
    }
  }

  dynamic processResponse(http.Response response, BuildContext? context) async {
    switch (response.statusCode) {
      case 200:
        {
          var responseJson = response.body;
          return responseJson;
        }
      case 201:
        {
          var responseJson = response.body;
          return responseJson;
        }
        break;
      case 422:
        {
          // statements;
        }
        break;
      case 426:
        {
          // update
          try {
            AppUpdateController appUpdateController = AppUpdateController();
            await appUpdateController.updateCheck(context);
          } catch (e) {
            showLog("there is an error in app update $e");
          }
        }
        break;
      case 401:
        {
          OauthObject oauthObject = await OauthMethods.getOauthInPreference();
          String clientSecret =
              await PreferenceHelper.getString(clientSecretKey);
          String applicationCode = '';
          if (Platform.isLinux) {
            applicationCode = applicationCodeLinux;
          } else if (Platform.isMacOS) {
            applicationCode = applicationCodeMac;
          } else if (Platform.isWindows) {
            applicationCode = applicationCodeWindows;
          }
          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          Map<String, dynamic> map = {
            applicationCodeKey: applicationCode,
            appVersionCodeKey:  (Platform.isAndroid) ? androidAppVersionCode : appVersionCode,
            grantTypeKey: 'refresh_token',
            refreshTokenKey: oauthObject.refreshToken,
            clientSecretKey: clientSecret
          };
          List<int> compressedData = compressJson(map.toString());
          var response = await http.post(Uri.parse('$baseUrl$refreshTokenURL'),
              body: jsonEncode(map));
          if (response.statusCode == 200) {
            RefreshToken refreshTokenResponse =
                await compute(refreshTokenFromJson, response);
            await OauthMethods.setOauthInPreference(OauthObject(
                expiresIn: refreshTokenResponse.expiresIn!,
                refreshToken: refreshTokenResponse.refreshToken!,
                accessToken: refreshTokenResponse.accessToken!));
            return reCallApi;
          } else {
            // logout and move to login page
          }
        }
        break;
      case 500:
        {
          // statements;
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
  }

  Future<dynamic> apiRequestMultipart(String url, Map<String, dynamic> map,
      {bool isShowProgress = true,
      bool showSnackBarIfError = true,
      BuildContext? context}) async {
    showLog('apiRequestMultipart ');
    if (url != deviceRegisterUrl) {
      if (url != appRegisterUrl) {
        String clientSecret = await PreferenceHelper.getString(clientSecretKey);
        map[clientSecretKey] = clientSecret;
      }
    }
    if (await OauthMethods.getLogin()) {
      OauthObject oauthObject = await OauthMethods.getOauthInPreference();
      jsonHeader['Authorization'] = 'Bearer ${oauthObject.accessToken}';
    }
    if (Platform.isLinux) {
      map[applicationCodeKey] = applicationCodeLinux;
    } else if (Platform.isMacOS) {
      map[applicationCodeKey] = applicationCodeMac;
    } else if (Platform.isWindows) {
      map[applicationCodeKey] = applicationCodeWindows;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    map[appVersionCodeKey] =
        (Platform.isAndroid) ? androidAppVersionCode : appVersionCode;

    showLog("Api req : $baseUrl$url");
    showLog("Header:$jsonHeader");
    showLog("Body:$map");
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$url'));

    // Adding headers
    jsonHeader.forEach((key, value) {
      request.headers[key] = value;
    });

    // Adding fields
    map.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Sending the request
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      showLog("Response : ${response.statusCode} \n ${response.body}");
      dynamic responseData = await processResponse(response, context);

      if (responseData == reCallApi) {
        return await apiRequest(
          url,
          map,
        );
      } else {
        return responseData;
      }
    } catch (e) {
      showLog("Response Error: $e");
    }
  }

  List<int> compressJson(String jsonData) {
    List<int> utf8Data = utf8.encode(jsonData);
    List<int> compressedData = gzip.encode(utf8Data);
    return compressedData;
  }
}
