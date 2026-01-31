import 'package:flutter/material.dart';

class Themes {
  static final light = ThemeData.light().copyWith(

      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.grey),
        titleMedium: TextStyle(color: Colors.grey),
        labelMedium: TextStyle(color: Colors.grey),
      ));
  static final dark = ThemeData.dark().copyWith(
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepPurple,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xfffec832)))),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.grey),
        titleMedium: TextStyle(color: Colors.grey),
        labelMedium: TextStyle(color: Colors.grey),
      ));
}
