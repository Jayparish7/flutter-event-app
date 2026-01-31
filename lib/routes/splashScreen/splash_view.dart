import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/splashScreen/splash_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  BaseWidget<SplashScreenController>? baseWidget;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    showLog("Splash screen view");
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    baseWidget = BaseWidget<SplashScreenController>(
      model: SplashScreenController(context: context),
      onModelReady: (model) => model.getInitialValues(),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            showLog("poping");
            Navigator.pop(context);
            return false;
          },
          child: Scaffold(
            body: showSplash(height, width, model),
          ),
        );
      },
    );
    return baseWidget!;
  }

  showSplash(double height, double width, SplashScreenController model) {
    return Container(
      decoration: const BoxDecoration(
        color: photomallBodyColor,
      ),
      height: height,
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Platform.isAndroid
                ? const SizedBox(
              height: 65,
            )
                : SizedBox.shrink(),
            AnimatedOpacity(
              opacity: model.opacity,
              duration: const Duration(seconds: 2),
              child: AnimatedScale(
                scale: model.scale,
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Image.asset('assets/images/event_manager_logo.png',
                      color: photomallColor, height: 120),
                ),
              ),
            ),
            Platform.isAndroid
                ? const SizedBox(
              height: 50,
            )
                : SizedBox.shrink(),
            Image.asset(
              'assets/images/poweredBy.png',
              height: 100,
              width: 330, color: Color(photomallYellow),
            ),

          ],
        ),
      ),
    );
  }
}
