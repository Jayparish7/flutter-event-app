import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../common_widgets/alert_dialog.dart';

StudioStore(BuildContext context,Function(String eventCode,String email) details) async {
  final RegExp emailRegEx = RegExp(
      "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$");

  PageController pageController = PageController(
    keepPage: true,
  );
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmPassWordController = TextEditingController();
  final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CommonAlertDialog(
         // scrollable: true,
         // contentPadding: EdgeInsets.zero,
          contentWidget: Stack(
            children: <Widget>[
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    showLog('jadsjhsadjk');
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.close,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ValueListenableBuilder<int>(
                      valueListenable: currentPage,
                      builder:
                          (BuildContext context, int page, Widget? child) {
                        return Center(
                            child: Text(page == 0 ? "Register" : "Set Password",
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: "Helvetica")));
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .50,
                    width: MediaQuery.of(context).size.width * .70,
                    child: PageView(
                        onPageChanged: (page) {
                          currentPage.value = page;
                          showLog("the page where $page");
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        children: [
                          getPage(
                            context,
                            passWordController,
                            confirmPassWordController,
                            (studio, email) => details(studio,email),
                          ),
                        ]),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}



String getErrorMessage(String user, String email,) {
  final RegExp emailRegEx = RegExp(
      "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$");

  if (user.isEmpty || email.isEmpty) {
    return 'please fill studio name & Email to continue';
  } else {
    if (!emailRegEx.hasMatch(email)) {
      return 'Please enter valid email';
    }
  }
  return "";
}

Widget getPage(
  BuildContext context,
  TextEditingController userController,
  TextEditingController emailController,
    Function(String studio,String email) details
) {
  Icon userIcon = const Icon(Icons.person);
  String passwordHintText = "studio name";
  Icon emailIcon = const Icon(Icons.email);
  String conformPasswordHintText = "email";
  final ValueNotifier<bool> showError = ValueNotifier<bool>(false);
  return Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * .70,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2))),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: Colors.grey.withOpacity(0.2)))),
                    child: Center(child: userIcon),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                        hintText: passwordHintText,
                        contentPadding: const EdgeInsets.only(left: 20),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintStyle: const TextStyle(
                            color: Colors.black26,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * .70,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2))),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: Colors.grey.withOpacity(0.2)))),
                    child: Center(child: emailIcon),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: conformPasswordHintText,
                        contentPadding: const EdgeInsets.only(left: 20),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintStyle: const TextStyle(
                            color: Colors.black26,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 5,
      ),
      CustomPrimaryButton(
        onPressed: () async {
          showError.value = false;

          final RegExp emailRegEx = RegExp(
              "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$");

          if (userController.text.isEmpty || emailController.text.isEmpty) {
            showError.value = true;
            return;
          } else {
            if (!emailRegEx.hasMatch(emailController.text)) {
              showError.value = true;
              return;
            }
          }
          await details(userController.text,emailController.text);
          Navigator.pop(context);
        },
        text: 'Submit',
      ),
      const SizedBox(
        height: 5,
      ),
      ValueListenableBuilder<bool>(
          valueListenable: showError,
          builder: (BuildContext context, bool value, Widget? child) {
            return AnimatedCrossFade(
              duration: const Duration(seconds: 1),
              firstChild: Text(
                  getErrorMessage(userController.text, emailController.text)),
              secondChild: const SizedBox(),
              crossFadeState:
                  value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            );
          })
    ],
  );
}
