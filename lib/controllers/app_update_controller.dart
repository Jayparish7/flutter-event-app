import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/app_update_response_model.dart';
import 'package:photomall_studio_manager/api/api_call.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/appUpdation/update_argument_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preference/preference_constants.dart';

class AppUpdateController {
  Future<void> updateCheck(BuildContext? context) async {
    Api api = Api(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    /// 0-[no update], 1-[update available], 2-[force update], 3-[close the app]

    AppUpdate? appUpdate = await api.appUpdateApiCall();
    showLog('appUpdateApiCall ${appUpdate?.appUpdateStatus}');
    await prefs.setString(updateStatusKey, appUpdate?.appUpdateStatus.toString()??'');

    switch (appUpdate?.appUpdateStatus) {
      case 0:
        {


        }
        break;
      case 1:
        {
          await   navigateToUpdate(context, 1);
        }
        break;
      case 2:
        {
          await navigateToUpdate(context, 2);
          showLog('navigateToUpdate');
        }
        break;
      case 3:
        {
          await  navigateToUpdate(context, 3);
        }
        break;
      default:
        {

        }
        break;
    }
  }

  Future<void> navigateToUpdate(BuildContext? context, int i) async {
    /*if(context != null && context.mounted)*/{
      showLog('navigateToUpdate');
   /*   await Navigator.pushNamed(context , RoutePaths.update,
          arguments: AppUpdateStatus(i));*/
     Get.toNamed(RoutePaths.update, arguments: AppUpdateStatus(i));

    }

  }

  // Function to check and update the app once per day
  Future<void> checkForAppUpdate(BuildContext? context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastCheckDate = prefs.getString(lastUpdateCheckKey);

    DateTime currentDate = DateTime.now();
    // Check if the last check date exists and if it's older than one day
    if (lastCheckDate != null) {
      DateTime lastCheck = DateTime.parse(lastCheckDate);
      // If it was checked today, return without checking again
      if (currentDate.difference(lastCheck).inDays < 1) {
        showLog('currentDate.difference $lastCheck');
        return;
      }
    }

    // If it's been more than a day or it's the first check, proceed with update check
    await updateCheck(context);

    // Save the current date as the last check date
    prefs.setString(lastUpdateCheckKey, currentDate.toIso8601String());
  }
}
