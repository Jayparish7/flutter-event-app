import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/common_widgets/common_elevated_button.dart';
import 'package:photomall_studio_manager/common_widgets/common_text.dart';
import 'package:photomall_studio_manager/oauth/oauth_methods.dart';
import 'package:photomall_studio_manager/preference/preference_constants.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';
import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';
import 'package:photomall_studio_manager/routes/1.constants/route_constants.dart';
import 'package:photomall_studio_manager/routes/studioDetail/event_argument_model.dart';
import 'package:photomall_studio_manager/utils/toast_util.dart';

import '../generated/l10n.dart';
import '../routes/languages/locale_provider.dart';
import 'common_appbar.dart';

getPopUpMenu(BuildContext context, bool isMain) {
  const TextStyle textStyle = TextStyle(
    color: Colors.white,
  );
  late final LanguageController languageController;
  languageController = Get.put(LanguageController());

  List<PopupMenuItem<int>> subPage = [
    PopupMenuItem<int>(
      value: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getIcon(Icons.home),
          Text(
            "Home",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getIcon(Icons.event_sharp),
          Text(
            "Events",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getIcon(
            Icons.logout,
          ),
          Text(
            "Logout",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
  ];
  List<PopupMenuItem<int>> mainPage = [
    PopupMenuItem<int>(
      value: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          getIcon(Icons.language),
          Text(
            S.of(context).languages,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    PopupMenuItem<int>(
      value: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          getIcon(Icons.logout),
          CommonText(
            text: S.of(context).logout,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
  ];
  return PopupMenuButton(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: const Color(photomallYellow),
      child: const Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Icon(
          Icons.more_vert,
          color: highlightedColor,
        ),
      ),
      itemBuilder: (context) {
        return isMain ? mainPage : subPage;
      },
      onSelected: (value) async {
        showLog("selected == > $value");
        if (value == 0) {
          var language = await PreferenceHelper.getString(languageSymbolKey);
          showLog('languageSymbolKey $language');
          language != ''
              ? languageController.currentLocale.value = language
              : null;
          _showLanguagePopup(context, languageController);
        } else if (value == 1) {
          String code = await getStudioCode();
          if (code.isNotEmpty) {
            if (context.mounted) {
              Navigator.pushNamed(context, RoutePaths.eventList,
                  arguments: EventArguments(code));

              /*    Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventListView(studioCode: code)),
              );*/
            }
          } else {
            if (context.mounted) {
              ToastUtil.getToast(context, "Error", "Can't navigate");
            }
          }
        } else if (value == 2) {
          var loading = false.obs;
          showModalBottomSheet(
              enableDrag: true,
              showDragHandle: true,
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return Obx(() {
                  return SizedBox(
                    height: 250,
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CommonText(
                            text:
                                S.of(context).are_you_sure_you_want_to_log_out),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              !loading.value?  CommonElevatedButton(
                                  onTap: () async {
                                    loading.value =true;
                                   await OauthMethods.setLogout(context);

                                    loading.value =false;

                                  },
                                  text: S.of(context).logout):CircularProgressIndicator(),
                              CommonElevatedButton(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  text: S.of(context).cancel)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                });
              });
        }
        //  Navigator.pop(context);
      });
}

void _showLanguagePopup(BuildContext context, LanguageController controller) {
  showModalBottomSheet(
    enableDrag: true,
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 500,
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close)),
                  Text(
                    S.of(context).choose_an_languages,
                    // Adjust this based on your localization setup
                    style: const TextStyle(
                        color: Color(photomallYellow),
                        // Replace with your color value
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return ListTile(
                    leading: Checkbox(
                      activeColor: const Color(photomallYellow),
                      value: controller.currentLocale.value == language.code,
                      onChanged: (bool? selected) {
                        if (selected == true) {
                          controller.setLocale(language.code, context);
                        }
                      },
                    ),
                    title: Text(language.name),
                    subtitle: Text(language.description),
                  );
                },
              )),
            ],
          ),
        ),
      );
    },
  );
}

List<LanguageFormat> languages = [
  LanguageFormat(
    code: 'en',
    name: 'English',
    description: 'App Language',
  ),
  LanguageFormat(
    code: 'ta',
    name: 'தமிழ்',
    description: 'Tamil',
  ),
  LanguageFormat(
    code: 'hi',
    name: 'हिन्दी',
    description: 'Hindi',
  ),
  LanguageFormat(
    code: 'fr',
    name: 'Français',
    description: 'French',
  ),
  LanguageFormat(
    code: 'kn',
    name: 'ಕನ್ನಡ',
    description: 'Kannada',
  ),
  LanguageFormat(
    code: 'ml',
    name: 'മലയാളം',
    description: 'Malayalam',
  ),
  LanguageFormat(
    code: 'mr',
    name: 'मराठी',
    description: 'Marathi',
  ),
  LanguageFormat(
    code: 'te',
    name: 'తెలుగు',
    description: 'Telugu',
  ),
  LanguageFormat(
    code: 'ms',
    name: 'Melayu',
    description: 'Malay',
  ),
];

getProgressMenu(BuildContext context, List<PopupMenuItem<int>> menuItems) {
  const TextStyle textStyle = TextStyle(
    color: Colors.white,
  );
  return PopupMenuButton(
      position: PopupMenuPosition.under,
      tooltip: '',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF003B73),
      child: Center(
        child: Row(
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white),
                child: Image.asset(
                  'assets/images/upload1.gif',
                  color: const Color(photomallYellow),
                  width: 25,
                )),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Uploading',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return menuItems;
      },
      onSelected: (value) async {
        showLog("selected == > $value");

        //  Navigator.pop(context);
      });
}

getIcon(IconData icon) {
  return Icon(
    icon,
    size: 20,
    color: Colors.white,
  );
}

Future<String> getStudioCode() async {
  return await PreferenceHelper.getString(eventCodePreferenceKey);
}
/*
var res = await PreferenceHelper.getString(studioDataKey);
TransporterResponse res1 =transporterResponseFromJson(res);
var res2 = res1.studiosData![0].data?.name;
showLog('res2res2res2res2 ${res2}');*/
