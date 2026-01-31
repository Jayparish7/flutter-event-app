//import 'package:auto_updater/auto_updater.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import '../../generated/l10n.dart';
import '../eventSubView/event_subview_route.dart';

class AppUpdate extends StatelessWidget {
  final int status;

  const AppUpdate({Key? key, required this.status}) : super(key: key);
  final String _feedURL = 'https://photomall.in/appcast.xml';

  @override
  Widget build(BuildContext context) {
    var packageName = "";

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      packageName = packageInfo.packageName;
    });
    Widget commonVerticalPadding = const SizedBox(
      height: 10,
    );
    Widget commonHorizontalPadding = const SizedBox(
      width: 10,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: (Platform.isAndroid)
          ? Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/update.png',
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                    const Text(
                      "Update Available",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "A new version of the app is available. Please update to continue using the app smoothly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: status != 2
                          ? MainAxisAlignment.spaceEvenly
                          : MainAxisAlignment.center,
                      children: [
                        status != 2
                            ? TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close warning
                                },
                                child: const Text("Remind Me Later"),
                              )
                            : const SizedBox(),
                        CustomPrimaryButton(
                          onPressed: () async {
                            LaunchReview.launch(
                                androidAppId: packageName, iOSAppId: "");
                            await Future.delayed(const Duration(seconds: 2), () {
                              SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
                            });

                            // Implement update functionality
                          },
                          text: "Update Now",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: IntrinsicHeight(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      commonHorizontalPadding,
                      Image.asset(
                        'assets/images/update.png',
                        height: MediaQuery.of(context).size.height * 0.6,
                      ),
                      commonHorizontalPadding,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).update,
                              style: const TextStyle(
                                  color: Color(photomallYellow),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60),
                            ),
                            commonVerticalPadding,
                            const Text(
                              appUpdate,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 25),
                            ),
                            commonVerticalPadding,
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  CommonElevatedButton(
                                    onTap: () async {
                                      showLog('launch taped');
                                      /*final url = Uri.parse(
                                  Platform.isAndroid
                                      ? "market://details?id=$packageName"
                                      : "https://apps.microsoft.com/detail/9pkgp7cgrv5m?ocid=webpdpshare&hl=en-gb&gl=IN",
                                );*/
                                      (Platform.isAndroid)
                                          ? LaunchReview.launch(
                                              androidAppId: packageName,
                                              iOSAppId: "")
                                          : (Platform.isMacOS)
                                              ? launchURL(
                                                  'https://photomall.in/en/downloads/event-manager')
                                              : launchURL(
                                                  'https://apps.microsoft.com/detail/9pkgp7cgrv5m?ocid=webpdpshare&hl=en-gb&gl=IN');
                                      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');

                                    },
                                    text: S.of(context).update,
                                  ),
                                  commonHorizontalPadding,
                                  status == 1
                                      ? CommonElevatedButton(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          text: S.of(context).later,
                                        )
                                      : CommonElevatedButton(
                                          onTap: () {
                                           Platform.isAndroid? SystemChannels.platform
                                                .invokeMethod<void>(
                                                    'SystemNavigator.pop'):exit(0);
                                          },
                                          text: S.of(context).close,
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      commonHorizontalPadding,
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void handleClickCheckForUpdates() async {
    //  await autoUpdater.setFeedURL(_feedURL);
    // await autoUpdater.checkForUpdates();
  }
}
