import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/common_appbar.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/utils/device_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preference/preference_constants.dart';

class WindowsActivationController {
  DeviceUtil deviceUtil = DeviceUtil();

  checkWindowsActivation(bool isActivate) async {
    bool isWindowsActivated = isActivate;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastCheckDate = prefs.getString(windowsActivationCheckKey);

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

    showLog("isWindowsActivated $isWindowsActivated");
    // if (!isWindowsActivated) {
    //   prefs.setString(windowsActivationCheckKey, currentDate.toIso8601String());
    //
    //   Get.to(() =>const WindowsActivationAlertScreen());
    // }
  }
}

class WindowsActivationAlertScreen extends StatefulWidget {
  const WindowsActivationAlertScreen({super.key});

  @override
  State<WindowsActivationAlertScreen> createState() =>
      _WindowsActivationAlertScreenState();
}

class _WindowsActivationAlertScreenState
    extends State<WindowsActivationAlertScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
          automaticallyImplyLeading: false,
          title: "Windows Activation Required"),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               Image.asset("assets/images/win_not_active.png",height: 300,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      // Default text style
                      children: [
                        TextSpan(
                          text:
                              " Your Windows operating system is not activated.\n ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "This may affect the performance and functionality of Photomall Event Manager.\n ",
                        ),
                        TextSpan(
                          text: "Please activate Windows ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        TextSpan(
                          text:
                              "to ensure smooth operation and avoid potential issues.",
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 20,
                    children: [
                      CustomPrimaryButton(
                        onPressed: () {
                          Process.run('cmd', ['/c', 'start ms-settings:activation']);

                        },
                        text: "Windows Settings",
                      ),
                      CustomPrimaryButton(
                        onPressed: () {
                          Get.back();
                        },
                        text: "Continue",
                      ),
                    ],
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
