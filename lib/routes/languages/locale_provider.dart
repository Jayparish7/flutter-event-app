 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photomall_studio_manager/preference/preference_helper.dart';

import '../../generated/l10n.dart';
import '../../preference/preference_constants.dart';
import '../1.constants/route_constants.dart';
import '../studioDetail/event_argument_model.dart';

class LanguageController extends GetxController{
  var currentLocale = 'en'.obs; // Default locale


  Future<void> setLocale(String locale,BuildContext context) async {
     await  PreferenceHelper.setString(languageSymbolKey, locale);
      S.load(Locale(locale));
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        RoutePaths.sideMenuView,
          arguments: SideMenuArguments(0)
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
  ].obs;

}

 class LanguageFormat {
   final String code; // Language code, e.g., 'en', 'ta', 'hi'
   final String name; // Display name of the language, e.g., 'English', 'தமிழ்'
   final String description; // Description of the language, e.g., 'App Language', 'Tamil'

   LanguageFormat({
     required this.code,
     required this.name,
     required this.description,
   });

 }