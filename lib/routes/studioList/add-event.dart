import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/common_widgets/photomall_progress.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../../common_widgets/alert_dialog.dart';
import '../../generated/l10n.dart';

addEvent(BuildContext context, Function(String eventCode) details) async {
  PageController pageController = PageController(
    keepPage: true,
  );
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmPassWordController = TextEditingController();
  final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder<bool>(
            valueListenable: loading,
            builder: (BuildContext context, bool value, Widget? child) {
              return IgnorePointer(
                ignoring: value,
                child: value
                    ? const PhotomallProgress()
                    : CommonAlertDialog(
                        titleWidget:const Center(
                          child:  Text(
                            "Add Event" ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        contentWidget: SizedBox(
                          width: 450,
                          child: Stack(
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                width: MediaQuery.of(context).size.width * .5,
                                child: PageView(
                                    onPageChanged: (page) {
                                      currentPage.value = page;
                                      showLog("the page where $page");
                                    },
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    controller: pageController,
                                    children: [
                                      getPage(
                                        context,
                                        passWordController,
                                        confirmPassWordController,
                                        (studio, email) async {
                                          loading.value = true;
                                          await details(studio);
                                          loading.value = false;
                                        },
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ),
              );
            });
      });
}

Future<void> addEventForAndroid(
    BuildContext context, Function(String eventCode) details) async {
  PageController pageController = PageController(
    keepPage: true,
  );
  TextEditingController passWordController = TextEditingController();
  TextEditingController confirmPassWordController = TextEditingController();
  final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  await showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (BuildContext context) {
      return ValueListenableBuilder<bool>(
        valueListenable: loading,
        builder: (BuildContext context, bool value, Widget? child) {
          return IgnorePointer(
            ignoring: value,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color:
                              Color(photomallYellow), // Use appropriate color
                        ),
                        child: const Center(
                          child: Text(
                            "Add Event",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (page) {
                            currentPage.value = page;
                          },
                          children: [
                            getPage(
                              context,
                              passWordController,
                              confirmPassWordController,
                              (studio, email) async {
                                loading.value = true;
                                await details(studio);
                                loading.value = false;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (value)
                  const Positioned.fill(
                    child: Center(child: PhotomallProgress()),
                  ),
                Positioned(
                  right: 20,
                  top: 18,
                  child: InkWell(
                    onTap: () {
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
              ],
            ),
          );
        },
      );
    },
  );
}

String getErrorMessage(
  String user,
  String email,
) {
  if (user.isEmpty || email.isEmpty) {
    return 'Please fill the Event code';
  }
  return "";
}

Widget getPage(
    BuildContext context,
    TextEditingController userController,
    TextEditingController emailController,
    Function(String studio, String email) details) {
  Icon eventIcon = const Icon(Icons.event_available);
  String passwordHintText = "Event code";

  final ValueNotifier<bool> showError = ValueNotifier<bool>(false);
  return Column(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: 50,
            width: Platform.isAndroid
                ? MediaQuery.of(context).size.width * .50
                : MediaQuery.of(context).size.width * .25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black)),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 30,
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.black))),
                    child: Center(child: eventIcon),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          CustomPrimaryButton(
            isLeadingIcon: true,
            icon: Icons.add,
            onPressed: () {
              showError.value = false;

              if (userController.text.isEmpty) {
                showError.value = true;
                return;
              } else {}
              details(userController.text, emailController.text);
            },
            text: S.of(context).add,
          ),
          CustomPrimaryButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: S.of(context).cancel,
          ),
        ],
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
