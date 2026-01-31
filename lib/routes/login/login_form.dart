import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:permission_handler/permission_handler.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/country_model.dart'
    as contry;
import 'package:photomall_studio_manager/common_widgets/common_countrycode_picker.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/login/login_controller.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import 'package:sign_in_button/sign_in_button.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

import '../../generated/l10n.dart';
import '../../utils/permission_util.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

import '../1.constants/route_constants.dart';

class LoginForm extends StatefulWidget {
  final Function callUserApi;
  final Function callOTPApi;
  final LoginController model;

  const LoginForm(
      {Key? key,
      required this.callUserApi,
      required this.callOTPApi,
      required this.model})
      : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  PageController pageController = PageController(
    keepPage: true,
  );

  String user = "";
  String errorMessage = "";
  bool errorMessageVisibility = false;
  TextEditingController emailOrMobileController = TextEditingController();

  final RegExp _mobileRegEx = RegExp(r'(^(?:[+0]9)?[0-9]{10,11}$)');
  final RegExp _emailRegEx = RegExp(
      "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$");
  TextEditingController otpTextController = TextEditingController();
  final ValueNotifier<bool> resendOtpTextEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<contry.Country> dropDownValue =
      ValueNotifier<contry.Country>(
          contry.Country(id: 108, shortCode: "IN", name: "india", code: "+91"));
  final ValueNotifier<bool> isPhoneNumber = ValueNotifier<bool>(false);
  final ValueNotifier<int> _resendOTPDelay = ValueNotifier<int>(resendOTPDelay);
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  String? _errorMessage;

  void _validateInput(String value) {
    setState(() {
      if (value.isEmpty) {
        _errorMessage =
            S.of(context).please_enter_a_valid_phone_number_or_email;
      } else if (RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
          .hasMatch(value)) {
        // It's a phone number, so check length
        if (value.length > 10) {
          _errorMessage =
              '${S.of(context).please_enter_a_valid_phone_number_or_email} (max 10 digits)';
        } else {
          _errorMessage = null; // Phone number is valid
        }
      } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        // It's an email, so it's valid
        _errorMessage = null;
      } else {
        _errorMessage =
            S.of(context).please_enter_a_valid_phone_number_or_email;
      }
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_resendOTPDelay.value < 1) {
        timer.cancel();
        resendOtpTextEnabled.value = true;
      } else {
        _resendOTPDelay.value = _resendOTPDelay.value - 1;
        resendOtpTextEnabled.value = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    emailOrMobileController.addListener(() {
      if (emailOrMobileController.text.isNotEmpty) {
        if (_isNumeric(emailOrMobileController.text) ||
            emailOrMobileController.text[0] == "+") {
          isPhoneNumber.value = true;
        } else {
          isPhoneNumber.value = false;
        }
        String data = emailOrMobileController.text;
        if (data.length >= 5 && data[0] == "+") {
          dropDownValue.value = seperatePhoneAndDialCode(data)!.object!;
          showLog('the phone number data where ${dropDownValue.value.code}');
        }
      }
    });
  }

  Future<void> performSignIn() async {
    final credentials = await googleSignIn.signIn();
    if (credentials != null) {
      bringAppToFront();

      await windowManager.focus();
      await windowManager.show();
      final parts = credentials.idToken!.split('.');
      if (parts.length == 3) {
        final payload = base64.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(payload));
        final data = json.decode(decoded);
        final email = data['email'];
        final name = data['name'];
        final picture = data['picture'];
        await widget.model
            .otpApi("1111", context, user: email, trueCaller: true);
        showLog('Email: $email');
        showLog('Name: $name');
        showLog('Photo URL: $picture');
      }
      showLog('Signed in successfully: ${credentials.scopes}');
    } else {
      showLog('Sign in failed');
    }
  }

  void bringAppToFrontLinux() async {
    try {
      // This assumes your app window has a recognizable name
      const windowName = "PhotomallStudioManager"; // change if needed

      // Search for window ID
      var result =
          await Process.run('xdotool', ['search', '--name', windowName]);
      if (result.exitCode == 0) {
        final windowId = result.stdout.toString().split('\n').first.trim();

        // Bring window to front
        await Process.run('xdotool', ['windowactivate', windowId]);
      } else {
        showLog("Window not found.");
      }
    } catch (e) {
      showLog("Error bringing app to front: $e");
    }
  }

  void bringAppToFront() async {
    if (Platform.isWindows) {
      final hWnd = GetForegroundWindow();
      SetForegroundWindow(hWnd);
    } else if (Platform.isMacOS) {
      await windowManager.focus();
    }
  }

  Future<dynamic> signInWithGoogle() async {
    try {
      showLog('signInWithGoogle signInWithGoogle');

      final google.GoogleSignInAccount? googleUser =
          await google.GoogleSignIn().signIn();
      showLog('userCredential $googleUser');

      final google.GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      showLog('userCredential $googleAuth');

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e, s) {
      ToastUtil.showSnackBarAtCurrentState("Something went wrong");
      showLog('exception->$e, .... $s');
    }
  }

  Future<void> performSignOut() async {
    await googleSignIn.signOut();
    showLog('Signed out successfully');
  }

  @override
  Widget build(BuildContext context) {
    double defaultPadding = 10.0;

    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: pageController,
      children: [
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ValueListenableBuilder<bool>(
              valueListenable: isPhoneNumber,
              builder: (BuildContext context, bool value, Widget? child) {
                return Container(
                  margin: EdgeInsets.only(
                      left: (Platform.isAndroid) ? 0 : 0,
                      right: (Platform.isAndroid) ? 25 : 0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: (Platform.isAndroid)
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                UniqueText(
                                  text:
                                      "${S.of(context).login}/${S.of(context).register}",
                                  color: photomallColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: defaultPadding,
                        ),
                        SizedBox(
                          height: defaultPadding,
                        ),
                        Visibility(
                          visible: value,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10,
                                      right: Platform.isAndroid ? 35 : 10),
                                  color: Colors.transparent,
                                  width: Platform.isAndroid
                                      ? constraints.maxWidth * 1
                                      : constraints.maxWidth * 1,
                                  height: constraints.maxWidth * 0.15,
                                  child: ValueListenableBuilder<contry.Country>(
                                      valueListenable: dropDownValue,
                                      builder: (BuildContext context,
                                          contry.Country itemValue,
                                          Widget? child) {
                                        return Card(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          shadowColor: photomallBodyColor,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 0.5,
                                                  color:
                                                      Color(photomallYellow)),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CustomCountryPicker(
                                              dropDownValue: itemValue.id!,
                                              onchangeDropDown: (int id) {
                                                contry.Country? value =
                                                    getObjectByCountryId(id);
                                                dropDownValue.value =
                                                    contry.Country(
                                                        id: 108,
                                                        shortCode: "IN",
                                                        name: "india",
                                                        code: "+91");
                                                if (emailOrMobileController
                                                    .text.isNotEmpty) {
                                                  if (emailOrMobileController
                                                          .text[0] ==
                                                      "+") {
                                                    contry.Country list =
                                                        seperatePhoneAndDialCode(
                                                                emailOrMobileController
                                                                    .text)!
                                                            .object!;

                                                    String counteryCode =
                                                        list.code!;
                                                    emailOrMobileController
                                                            .text =
                                                        emailOrMobileController
                                                            .text
                                                            .replaceAll(
                                                                counteryCode,
                                                                value!.code!);
                                                  }
                                                }
                                                setState(() {
                                                  onChangeValidation(
                                                      emailOrMobileController
                                                          .text);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: defaultPadding * 2,
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: constraints.minWidth,
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextFormField(
                                cursorColor: Colors.blueGrey,

                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                              .hasMatch(value) &&
                                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(value)) ||
                                      (isPhoneNumber.value == true &&
                                          (!RegExp(r'^\d{10}$')
                                              .hasMatch(value)))) {
                                    return S
                                        .of(context)
                                        .please_enter_a_valid_phone_number_or_email;
                                  }
                                  return null;
                                },

                                onChanged: (value) {
                                  showLog(
                                      'onChanged $value:${emailOrMobileController.text}');
                                  // _validateInput(value);
                                },
                                //onSubmitted: (value) {},
                                controller: emailOrMobileController,
                                decoration: InputDecoration(
                                  labelText: S.of(context).phone_email_address,
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(photomallYellow),
                                          width: 1.0)),
                                  errorText: _errorMessage,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: defaultPadding * 2,
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomPrimaryButton(
                                onPressed: () async {
                                  emailOrMobileController.text =
                                      emailOrMobileController.text.trim();
                                  if (Platform.isAndroid) {
                                    // if (!await FlutterForegroundTask
                                    //     .canDrawOverlays) {
                                    //   requestPermissionForAndroid(context);
                                    //   return;
                                    // }
                                    var status =
                                        await requestStoragePermission();
                                    showLog("requestStoragePermission $status");
                                    if (status != true) {
                                      return;
                                    }
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    var emailOrMobile =
                                        emailOrMobileController.text;
                                    if (emailOrMobile.isEmpty) {
                                      setState(() {});
                                      ToastUtil.getToast(
                                          context,
                                          S.of(context).empty,
                                          S
                                              .of(context)
                                              .please_enter_your_phone_email);
                                      return;
                                    }
                                    if (emailOrMobile.isNotEmpty) {
                                      if (emailOrMobileController.text[0] ==
                                          "+") {
                                        String? phoneNumber =
                                            seperatePhoneAndDialCode(
                                                    emailOrMobileController
                                                        .text)!
                                                .phoneNumber;
                                        if (phoneNumber != null) {
                                          emailOrMobileController.text =
                                              phoneNumber;
                                        }
                                      }
                                      //user enter mobile number, so login with mobile
                                    }

                                    bool status = await widget.callUserApi(
                                        emailOrMobileController.text,
                                        dropDownValue.value.id);

                                    pageController
                                        .animateToPage(1,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeIn)
                                        .then((value) {
                                      user = emailOrMobileController.text;
                                      setState(() {});
                                    });
                                  } else {
                                    setState(() {});
                                  }
                                },
                                text: S.of(context).next,
                                icon: Icons.arrow_forward_ios,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SignInButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          Buttons.google,
                          text: "Sign in with Google",
                          onPressed: () async {
                            if (Platform.isAndroid) {
                              if (!await FlutterForegroundTask
                                  .canDrawOverlays) {
                                requestPermissionForAndroid(context);
                                return;
                              }
                              var status = await requestStoragePermission();
                              showLog("requestStoragePermission $status");
                              if (status != true) {
                                return;
                              }
                            }
                            if (Platform.isAndroid) {
                              ValueNotifier userCredential = ValueNotifier('');
                              try {
                                userCredential.value = await signInWithGoogle();
                              } catch (e) {
                                showLog('userCredential exception $e');
                              }
                              if (userCredential.value != null) {
                                showLog(
                                    'signInWithGoogle ${userCredential.value.user!.email}');
                                var email = userCredential.value.user!.email;
                                await widget.model.otpApi("1111", context,
                                    user: email, trueCaller: true);
                              }
                            } else {
                              performSignOut();
                              performSignIn();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              });
        }),
        Container(
          margin:
              EdgeInsets.only(left: (Platform.isAndroid) ? 10 : 63, right: 50),
          child: Center(
            child: ListView(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //  header(),
                const SizedBox(
                  height: 25,
                ),

                SizedBox(
                  height: 80,
                  //  width: contentWidth,

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: CommonText(
                          text: S.of(context).otp,
                          isHeading: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: defaultPadding,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CommonText(
                        text:
                            "${S.of(context).please_enter_the_OTP_send_to} \n${isPhoneNumber.value == true ? (dropDownValue.value.code) : ''} $user",
                        isBody: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: defaultPadding,
                ),
                SizedBox(
                  height: defaultPadding,
                ),
                ValueListenableBuilder<bool>(
                    valueListenable: resendOtpTextEnabled,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return getOtpFeild(context, (String pin) {
                          showLog('the otp where $pin');
                          widget.callOTPApi(pin);
                        }, constraints);
                      });
                    }),
                SizedBox(
                  height: defaultPadding * 2,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomPrimaryButton(
                      isLeadingIcon: true,
                      onPressed: () {
                        pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      icon: Icons.arrow_back_ios,
                      text: S.of(context).back,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: resendOtpTextEnabled,
                        builder:
                            (BuildContext context, bool value, Widget? child) {
                          return value
                              ? TextButton(
                                  onPressed: () {
                                    resendOtpTextEnabled.value =
                                        !resendOtpTextEnabled.value;
                                    startTimer();
                                  },
                                  child: CommonText(
                                    text: S.of(context).resend_otp,
                                    isBody: true,
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {},
                                  child: ValueListenableBuilder<int>(
                                      valueListenable: _resendOTPDelay,
                                      builder: (BuildContext context, int timer,
                                          Widget? child) {
                                        return CommonText(
                                          text: "$timer sec",
                                          isBody: true,
                                        );
                                      }),
                                );
                        }),
                  ],
                ),
                SizedBox(
                  height: defaultPadding * 2,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  bool _isNumeric(String str) {
    String source = str.trim();
    if (source == null) {
      return false;
    }
    return double.tryParse(source) != null;
  }

  contry.Country? getObjectByCountryId(int id) {
    contry.Country foundedCountry;
    for (contry.Country country in allCountries!) {
      int? id = country.id;
      if (id == id) {
        foundedCountry = country;
        return foundedCountry;
      }
    }
    return null;
  }

  Tuple? seperatePhoneAndDialCode(String phoneWithDialCode) {
    contry.Country? foundedCountry;
    for (contry.Country country in allCountries!) {
      String dialCode = country.code.toString();
      if (phoneWithDialCode.contains(dialCode)) {
        foundedCountry = country;
      }
    }
    if (foundedCountry != null) {
      var dialCode = phoneWithDialCode.substring(
        0,
        foundedCountry.code!.length,
      );
      var newPhoneNumber = phoneWithDialCode.substring(
        foundedCountry.code!.length,
      );
      return Tuple(phoneNumber: newPhoneNumber, object: foundedCountry);
    } else {
      print("country code empty");
    }
    return null;
  }

  onChangeValidation(String value) {
    errorMessageVisibility = false;
    if (value.isEmpty) {
      setState(() {
        errorMessage = S.of(context).please_fill_this_field;
        errorMessageVisibility = true;
      });
      return null;
    } else {
      String data = value;
      if (value[0] == "+") {
        data.replaceAll('+', '');
      }
      if (value.isNotEmpty &&
          (_isNumeric(value) || (value[0] == "+" && _isNumeric(data)))) {
        if (value[0] != "+") {
          if (dropDownValue.value.code == '+91') {
            if (value.length != 10) {
              errorMessageVisibility = true;
            } else {
              errorMessageVisibility = false;
            }
          }
        }
        if (_isNumeric(value) &&
            value.length != 13 &&
            dropDownValue.value.code == '+91' &&
            value[0] == "+" &&
            value[1] == "9" &&
            value[2] == "1") {
          errorMessageVisibility = true;
        }
        if (_isNumeric(value) &&
            value.length == 13 &&
            dropDownValue.value.code == '+91' &&
            value[0] == "+" &&
            value[1] == "9" &&
            value[2] == "1") {
          showLog('india number is valid  ${dropDownValue.value.code}');
          errorMessageVisibility = false;
        }
        if (!_mobileRegEx.hasMatch(value) &&
            dropDownValue.value.code == '+91') {
          if (_formKey.currentState!.validate()) {}
          setState(() {
            errorMessage =
                S.of(context).please_enter_a_valid_phone_number_or_email;
            errorMessageVisibility = true;
          });
          return null;
        }
      } else if (!_emailRegEx.hasMatch(value)) {
        setState(() {
          errorMessage =
              S.of(context).please_enter_a_valid_phone_number_or_email;
          errorMessageVisibility = true;
        });
        return null;
      } else {
        setState(() {
          errorMessageVisibility = false;
        });
      }
      return null;
    }
  }

  getOtpFeild(
    BuildContext context,
    Function otpOnComplete,
    BoxConstraints constraints,
  ) {
    return Row(
      mainAxisAlignment: (Platform.isAndroid)
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        OtpTextField(
          enabledBorderColor: Colors.grey,
          focusedBorderColor: const Color(photomallYellow),
          cursorColor: Colors.grey,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          fieldWidth: constraints.maxWidth * 0.2,
          numberOfFields: 4,
          borderColor: const Color(photomallYellow),
          //set to true to show as box or false to show as dash
          showFieldAsBox: true,
          //runs when a code is typed in
          onCodeChanged: (String code) {},
          //runs when every textfield is filled
          onSubmit: (String verificationCode) {
            otpOnComplete(verificationCode);
          }, // end onSubmit
        ),
      ],
    );
  }

  Widget header() {
    return Image.asset(
      photomallLogo,
      color: const Color(photomallYellow),
    );
  }

/* Widget footer() {
    return const Column(
      children: [

        SizedBox(height: 30,),
        CommonText(
          text: "Powered by Photomall",
          style: TextStyle(fontSize: 20,
            fontStyle: FontStyle.italic

          ),
        ),
      ],
    );
  }*/
}

@pragma('vm:entry-point')
GoogleSignIn googleSignIn = GoogleSignIn(
  params: const GoogleSignInParams(
    clientId:
        '1045044141795-83g7ieg2bsrlsqb4nlothlkok9vl0hlg.apps.googleusercontent.com',
    clientSecret: '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',
    redirectPort: 3000,
    scopes: [
      //'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/drive',
    ],
  ),
);
