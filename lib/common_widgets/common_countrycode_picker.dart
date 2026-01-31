import 'dart:io';

import 'package:country_flags/country_flags.dart';

import 'package:flutter/material.dart';
import 'package:photomall_studio_manager/api/apiResponseModels/country_model.dart'
    as contry;
import 'package:photomall_studio_manager/routes/login/login_controller.dart';

import '../routes/1.constants/common_constants.dart';

class CustomCountryPicker extends StatefulWidget {
  //final Map<String, dynamic> dropDownValue;
  int dropDownValue;
  final Function onchangeDropDown;

  CustomCountryPicker(
      {Key? key,
      /*this.dropDownValue = const {
        "id": 108,
        "code": "+91",
        "name": "India",
        "short_code": "IN"
      },*/
      this.dropDownValue = 108,
      required this.onchangeDropDown})
      : super(key: key);

  @override
  State<CustomCountryPicker> createState() => _CustomCountryPickerState();
}

class _CustomCountryPickerState extends State<CustomCountryPicker> {
  List<contry.Country> dropDownItems = [];

  @override
  void initState() {
    getDroupDownItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
          isExpanded: true,
          autofocus: false,
          focusColor: Colors.transparent,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.centerLeft,
          style: Theme.of(context).textTheme.titleMedium,
          iconDisabledColor: Colors.black,
          iconEnabledColor: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(
            Icons.arrow_drop_down, color: Colors.black,
            //color: AppColorData.iconColor,
          ),
          value: widget.dropDownValue,
          dropdownColor: photomallBodyColor,
          items: dropDownItems
              .map((contry.Country items) => DropdownMenuItem<int>(
                  value: items.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (!Platform.isLinux)
                          ? Padding(
                            padding: const EdgeInsets.only(right  : 5.0),
                            child: CountryFlag.fromCountryCode(
                              items.shortCode!,
                              height: 20,
                              width: 20,shape: const RoundedRectangle(2),
                            ),
                          )
                          : Text(convertToEmoji(items.shortCode!)),
                      Text(
                        items.name!,
                        style: const TextStyle(
                            color: Color(photomallYellow),
                            fontSize: 13,
                            decorationStyle: TextDecorationStyle.wavy),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(items.code!,
                          style: const TextStyle(
                              color: Color(photomallYellow), fontSize: 13)),
                    ],
                  )))
              .toList(),
          onChanged: (int? newValue) {
            widget.dropDownValue = newValue!;
            setState(() {});

            widget.onchangeDropDown(newValue);
          }),
    );
  }

  void getDroupDownItems() async {
    // LoginController loginController = LoginController();
    dropDownItems = allCountries!;
  }

  static String convertToEmoji(String countryCode) {
    String flag = countryCode.replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }
}
