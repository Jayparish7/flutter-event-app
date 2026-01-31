import 'dart:convert';

import 'package:photomall_studio_manager/routes/1.constants/common_constants.dart';

import '../api/apiResponseModels/country_model.dart';
import '../preference/preference_constants.dart';
import '../preference/preference_helper.dart';
import '../routes/login/login_controller.dart';

class CommonUtils {
  static  separatePhoneAndDialCode(
      String phoneWithDialCode) async {
    Country? foundedCountry;
    String countriesString =
        await PreferenceHelper.getString(countryPreferenceKey);
    allCountries = List<Country>.from(
        json.decode(countriesString).map((x) => Country.fromJson(x)));
    for (Country country in allCountries!) {
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
      showLog("country code empty");
    }
    return null;
  }

  static   Country? getObjectByCountryId(int id) {
    Country foundedCountry;
    for (Country country in allCountries!) {
      int? id = country.id;
      if (id == id) {
        foundedCountry = country;
        return foundedCountry;
      }
    }
    return null;
  }


  static setCountriesValue() async {
    String countriesString =
        await PreferenceHelper.getString(countryPreferenceKey);
    allCountries = List<Country>.from(
        json.decode(countriesString).map((x) => Country.fromJson(x)));

  }

}
