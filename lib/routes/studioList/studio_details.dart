import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

getStudioDetails(BuildContext context) async {
  PageController pageController = PageController(
    keepPage: true,
  );
  TextEditingController studioNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: <Widget>[
              Positioned(
                right: 0,
                top: 0,
                child: InkResponse(
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
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.3)))),
                    child: const Center(
                        child: Text("Register",
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontFamily: "Helvetica"))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .50,
                    width: MediaQuery.of(context).size.width * .70,
                    child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        children: [
                          getPage(
                              context,
                              const Icon(Icons.person),
                              "Studio Name",
                              studioNameController,
                              pageController,
                              0,
                              (String? value) {}),
                          getPage(
                              context,
                              const Icon(Icons.email),
                              "Email",
                              emailController,
                              pageController,
                              1,
                              (String? value) {}),
                        ]),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

Widget getPage(
    BuildContext context,
    Icon icon,
    String hintText,
    TextEditingController textEditingController,
    PageController pageController,
    int page,
    Function value,
    {TextEditingController? password}) {
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
                    child: Center(child: icon),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: hintText,
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
      page != 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                page == 0
                    ? const SizedBox()
                    : CommonElevatedButton(
                        onTap: () {
                          showLog('${page - 1} << ');
                          showError.value = false;
                          pageController.animateToPage(page - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                          showLog('${page - 1} << ');
                        },
                        text: 'Previous',
                      ),
                const SizedBox(
                  width: 5,
                ),
                CommonElevatedButton(
                  onTap: () {
                    if (page == 1) {
                      RegExp emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (textEditingController.text.isNotEmpty &&
                          emailValid.hasMatch(textEditingController.text)) {
                        showError.value = false;
                        pageController.animateToPage(page + 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      } else {
                        showError.value = true;
                      }
                    } else {
                      if (textEditingController.text.isNotEmpty) {
                        showError.value = false;
                        pageController.animateToPage(page + 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      } else {
                        showError.value = true;
                      }
                    }
                  },
                  text: 'Next',
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                page == 0
                    ? const SizedBox()
                    : CommonElevatedButton(
                        onTap: () {
                          showLog('${page - 1} << ');
                          showError.value = false;
                          pageController.animateToPage(page - 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                          showLog('${page - 1} << ');
                        },
                        text: 'Previous',
                      ),
                const SizedBox(
                  width: 5,
                ),
                CommonElevatedButton(
                  onTap: () {
                    if (password?.text == textEditingController.text) {
                      showError.value = false;
                    } else {
                      showError.value = true;
                    }
                  },
                  text: 'Submit',
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
              firstChild: page != 4
                  ? page == 2
                      ? const Text("please fill valid email")
                      : const Text("please fill this field")
                  : const Text("pass word does't match"),
              secondChild: const SizedBox(),
              crossFadeState:
                  value ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            );
          })
    ],
  );
}
