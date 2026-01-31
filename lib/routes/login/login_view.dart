import 'dart:io';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photomall_studio_manager/common_widgets/base_widget.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/main.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/login/login_controller.dart';
import 'package:photomall_studio_manager/routes/login/login_form.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  BaseWidget<LoginController>? baseWidget;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    double cardWidth = 1000 < width ? width * .30 : width * .75;
    double cardHeight = height > 600 ? height * .70 : height * .90;

    double defaultPadding = 10.0;

    return Builder(builder: (context) {
      showLog("the width $height");
      baseWidget = BaseWidget<LoginController>(
        model: LoginController(context: context),
        onModelReady: (model) => model.getInitialValues(context),
        builder: (context, model, child) {
          return Scaffold(
              body: Platform.isAndroid
                  ? DoubleBackToCloseApp(
                      snackBar: const SnackBar(
                        content: Text('Tap back again to leave'),
                      ),
                      child: login(cardWidth, model, cardHeight))
                  : login(cardWidth, model, cardHeight));
        },
      );

      return baseWidget!;
    });
  }

  Widget login(double cardWidth, LoginController model, double cardHeight) {
    return ValueListenableBuilder<bool>(
        valueListenable: model.isLoading,
        builder: (BuildContext context, bool value, Widget? child) {
          var size = MediaQuery.of(context).size;

          return IgnorePointer(
            ignoring: value,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: photomallBodyColor,
                /* image: (!Platform.isAndroid)
                    ? const DecorationImage(
                        image: AssetImage('assets/images/login.png'),
                        alignment: Alignment.centerLeft,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.contain,
                        scale: .6)
                    : null,*/
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Row(
                  children: [
                    !Platform.isAndroid
                        ? Container(
                            width: MediaQuery.of(context).size.width * .5,
                            color: photomallColor, //Color(0xFF445162),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: photomallBodyColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Image.asset(
                                    photomallCameraLogo,
                                    color: const Color(photomallYellow),
                                    height: MediaQuery.of(context).size.height *
                                        .08,
                                  ),
                                ),
                                const Text(
                                  "Photomall",
                                  style: TextStyle(
                                    fontSize: 30,
                                    letterSpacing: 3,
                                    color: photomallBodyColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Event Management System",
                                  style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 2,
                                    color: photomallBodyColor,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                const Text(
                                  textAlign: TextAlign.center,
                                  "A Powerful,yet easy to use application for managing event photos",
                                  style: TextStyle(
                                    fontSize: 15,
                                    letterSpacing: 2,
                                    color: photomallBodyColor,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: Platform.isAndroid ? 140 : 0,
                            left: (Platform.isAndroid) ? 7 : 0,
                            //right: (Platform.isAndroid) ? 0 : size.width*.1
                          ),
                          child: SizedBox(
                            width: (Platform.isAndroid) ? 400 : cardWidth,
                            height: (Platform.isAndroid) ? 500 : cardHeight,
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: (Platform.isAndroid)
                                        ? 0.0
                                        : size.height * 0.1,
                                    left: (Platform.isAndroid) ? 25.0 : 0),
                                child: Stack(
                                  children: [
                                    LoginForm(
                                      model: model,
                                      callUserApi: (value, id) async {
                                        return await model.userApi(value, id);
                                      },
                                      callOTPApi: (value) async {
                                        await model.otpApi(value, context);
                                      },
                                    ),
                                    value
                                        ? const Positioned.fill(
                                            child: PhotomallProgress())
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget header() {
    return Image.asset(
      photomallLogo,
      color: const Color(photomallYellow),
      height: (Platform.isAndroid)
          ? MediaQuery.of(context).size.height * .05
          : MediaQuery.of(context).size.height * .05,
    );
  }
}
