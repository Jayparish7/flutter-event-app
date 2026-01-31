import 'package:flutter/material.dart';

import '../routes/1.constants/common_constants.dart';

class CommonTextField {
  static InputDecoration getTextFieldDecoration(Widget? icon,
      {required String hintText, required String labelText}) {
    InputDecoration decoration = InputDecoration(
        icon: icon,
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(
            color: Color(photomallYellow), fontWeight: FontWeight.w600),
        focusColor: const Color(photomallYellow),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ));
    return decoration;
  }
}
